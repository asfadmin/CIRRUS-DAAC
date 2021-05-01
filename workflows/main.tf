terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.19.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 2.1.0"
    }
  }
  backend "s3" {
  }
}

provider "aws" {
  ignore_tags {
    key_prefixes = ["gsfc-ngap"]
  }
}

module "acme_workflow" {

  source = "https://github.com/nasa/cumulus/releases/download/v6.0.0/terraform-aws-cumulus-s3-replicator.zip"

  prefix          = local.prefix
  name            = "ACMEWorkflow"
  workflow_config = data.terraform_remote_state.cumulus.outputs.workflow_config
  system_bucket   = local.system_bucket
  tags            = local.default_tags

  state_machine_definition = templatefile("./acme.json", {
    task_arn = aws_lambda_function.nop_lambda.arn
  })
}

locals {
  prefix        = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}"
  system_bucket = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}-internal"
  default_tags = {
    Deployment = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}"
  }

  cumulus_remote_state_config = {
    bucket = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}-tf-state-${substr(data.aws_caller_identity.current.account_id, -4, 4)}"
    key    = "cumulus/terraform.tfstate"
    region = data.aws_region.current.name
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "terraform_remote_state" "cumulus" {
  backend   = "s3"
  workspace = var.DEPLOY_NAME
  config    = local.cumulus_remote_state_config
}

resource "aws_lambda_layer_version" "lambda_dependencies" {
  filename   = "${var.DIST_DIR}/lambda_dependencies_layer.zip"
  layer_name = "${local.prefix}-lambda_dependencies"

  compatible_runtimes = ["python3.7"]
}

resource "aws_lambda_function" "nop_lambda" {
  filename         = "${var.DIST_DIR}/lambdas.zip"
  function_name    = "${local.prefix}-nop"
  role             = data.terraform_remote_state.cumulus.outputs.lambda_processing_role_arn
  handler          = "lambdas.nop.lambda_handler"
  layers           = [aws_lambda_layer_version.lambda_dependencies.arn]
  timeout          = 10
  source_code_hash = filebase64sha256("${var.DIST_DIR}/lambdas.zip")

  runtime = "python3.7"
}
