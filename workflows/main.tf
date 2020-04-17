terraform {
  required_providers {
    aws  = "~> 2.46.0"
    null = "~> 2.1.0"
  }
  backend "s3" {
  }
}

provider "aws" {
}

module "acme_workflow" {
  source = "https://github.com/nasa/cumulus/releases/download/v1.17.0/terraform-aws-cumulus-workflow.zip"

  prefix                   = local.prefix
  name                     = "ACMEWorkflow"
  workflow_config          = data.terraform_remote_state.cumulus.outputs.workflow_config
  system_bucket            = local.system_bucket
  tags                     = local.default_tags

  state_machine_definition = templatefile("./acme.json", {
    "ParseMetadataLambdaArn" = aws_lambda_function.parse_metadata.arn,
    "StageGranuleFilesArn" = aws_lambda_function.stage_granule_files.arn,
    "GenerateEcho10Arn" = aws_lambda_function.generate_echo10.arn,
    "PostToCmrArn" = data.terraform_remote_state.cumulus.outputs.post_to_cmr_task.task_arn,
    "ReportToASFArn" = aws_lambda_function.report_to_asf.arn,
    "RemoveGranulesArn" = aws_lambda_function.remove_granules.arn
  })
}

locals {
  prefix = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}"
  system_bucket = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}-internal"
  default_tags = {
    Deployment = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}"
  }

  cumulus_remote_state_config = {
    bucket = "cumulus-${var.MATURITY}-tf-state"
    key    = "cumulus/terraform.tfstate"
    region = "${data.aws_region.current.name}"
  }

  rain_md_sqs = {
    "dev" = "https://sqs.us-west-2.amazonaws.com/117169578524/RAIN-MD-QUEUE-DEV"
    "int" = "https://sqs.us-west-2.amazonaws.com/117169578524/RAIN-MD-QUEUE-DEV"
    "test" = "https://sqs.us-west-2.amazonaws.com/117169578524/RAIN-MD-QUEUE-TEST"
    "prod" = "https://sqs.us-west-2.amazonaws.com/484422453661/RAIN-MD-QUEUE-PROD"
  }
}

data "aws_region" "current" {}

data "terraform_remote_state" "cumulus" {
  backend = "s3"
  workspace = "${var.DEPLOY_NAME}"
  config  = local.cumulus_remote_state_config
}

data "aws_arn" "lambda_processing_role" {
  arn = data.terraform_remote_state.cumulus.outputs.lambda_processing_role_arn
}

resource "aws_lambda_layer_version" "lambda_dependencies" {
  // makes layer with requirements.txt items.
  filename   = "${var.DIST_DIR}/lambda_dependencies_layer.zip"
  layer_name = "${local.prefix}-lambda_dependencies"

  compatible_runtimes = ["python3.7"]
}

resource "aws_s3_bucket" "acme_landing" {
  // zipfiles land here
  bucket = "${local.prefix}-acme-landing"
}

resource "aws_sqs_queue" "acme_workflow_dlq" {
  name = "${local.prefix}-acme-workflow-queue-dlq"
  message_retention_seconds = 86400
}

resource "aws_sqs_queue" "acme_workflow" {
  name = "${local.prefix}-acme-workflow-queue"
  visibility_timeout_seconds = 60 * 5
  message_retention_seconds = 86400
  redrive_policy            = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.acme_workflow_dlq.arn
    maxReceiveCount     = 4
  })
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:*:*:${local.prefix}-acme-workflow-queue",
      "Condition": {
        "ArnEquals": { "aws:SourceArn": "${aws_s3_bucket.acme_landing.arn}" }
      }
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_notification" "acme_landing_notification" {
  bucket = aws_s3_bucket.acme_landing.id

  queue {
    queue_arn     = aws_sqs_queue.acme_workflow.arn
    events        = ["s3:ObjectCreated:*"]
  }
}

# IAM Policy & Attachment to allowe Lambda role to SQS outside of the account (ie back to ASF)
resource "aws_iam_policy" "lambda_role_sqs_policy" {
  name        = "${local.prefix}-lambda_role_sqs_policy"
  path        = "/service-role/"
  description = ""

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "SQS:SendMessage",
        "SQS:GetQueueUrl"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "lambda_role_sqs_policy-attachment" {
  policy_arn = aws_iam_policy.lambda_role_sqs_policy.arn
  role       = element(reverse(split("/",data.aws_arn.lambda_processing_role.resource)),0)
}

resource "aws_lambda_function" "cumulus_adapter" {
  filename      = "${var.DIST_DIR}/lambdas.zip"
  function_name = "${local.prefix}-cumulus_adapter"
  role          = data.terraform_remote_state.cumulus.outputs.lambda_processing_role_arn
  handler       = "lambdas.cumulus_adapter.lambda_handler"
  layers        = [aws_lambda_layer_version.lambda_dependencies.arn]

  source_code_hash = filebase64sha256("${var.DIST_DIR}/lambdas.zip")

  runtime = "python3.7"
}

resource "aws_lambda_function" "parse_metadata" {
  filename      = "${var.DIST_DIR}/lambdas.zip"
  function_name = "${local.prefix}-parse_metadata"
  role          = data.terraform_remote_state.cumulus.outputs.lambda_processing_role_arn
  handler       = "lambdas.parse_metadata.lambda_handler"
  layers        = [aws_lambda_layer_version.lambda_dependencies.arn]
  timeout       = 10

  source_code_hash = filebase64sha256("${var.DIST_DIR}/lambdas.zip")

  environment {
    variables = {
      DATA_CENTER = "cumulus-${var.MATURITY}"
    }
  }

  runtime = "python3.7"
}

resource "aws_lambda_function" "stage_granule_files" {
  filename      = "${var.DIST_DIR}/lambdas.zip"
  function_name = "${local.prefix}-stage_granule_files"
  role          = data.terraform_remote_state.cumulus.outputs.lambda_processing_role_arn
  handler       = "lambdas.stage_granule_files.lambda_handler"
  layers        = [aws_lambda_layer_version.lambda_dependencies.arn]
  timeout       = 30

  source_code_hash = filebase64sha256("${var.DIST_DIR}/lambdas.zip")

  runtime = "python3.7"
}

resource "aws_lambda_function" "generate_echo10" {
  filename      = "${var.DIST_DIR}/lambdas.zip"
  function_name = "${local.prefix}-generate_echo10"
  role          = data.terraform_remote_state.cumulus.outputs.lambda_processing_role_arn
  handler       = "lambdas.generate_echo10.lambda_handler"
  layers        = [aws_lambda_layer_version.lambda_dependencies.arn]
  timeout       = 10

  source_code_hash = filebase64sha256("${var.DIST_DIR}/lambdas.zip")

  environment {
    variables = {
      DISTRIBUTION_HOST = "datapool${var.MATURITY == "prod" ? "" : "-${var.MATURITY}"}.asf.alaska.edu"
    }
  }

  runtime = "python3.7"
}

resource "aws_lambda_function" "report_to_asf" {
  filename      = "${var.DIST_DIR}/lambdas.zip"
  function_name = "${local.prefix}-report_to_asf"
  role          = data.terraform_remote_state.cumulus.outputs.lambda_processing_role_arn
  handler       = "lambdas.report_to_asf.lambda_handler"
  layers        = [aws_lambda_layer_version.lambda_dependencies.arn]
  timeout       = 10

  source_code_hash = filebase64sha256("${var.DIST_DIR}/lambdas.zip")

  environment {
    variables = {
      ASF_RAIN_MD_SQS = local.rain_md_sqs[var.MATURITY]
      BUCKET_PREFIX = "${local.prefix}-"
    }
  }

  runtime = "python3.7"
}

resource "aws_lambda_function" "remove_granules" {
  filename      = "${var.DIST_DIR}/lambdas.zip"
  function_name = "${local.prefix}-remove_granules"
  role          = data.terraform_remote_state.cumulus.outputs.lambda_processing_role_arn
  handler       = "lambdas.remove_granules.lambda_handler"
  layers        = [aws_lambda_layer_version.lambda_dependencies.arn]
  timeout       = 10

  source_code_hash = filebase64sha256("${var.DIST_DIR}/lambdas.zip")

  runtime = "python3.7"
}
