module "acme_workflow" {

  source = "https://github.com/nasa/cumulus/releases/download/v17.0.0/terraform-aws-cumulus-workflow.zip"

  prefix          = local.prefix
  name            = "ACMEWorkflow"
  workflow_config = data.terraform_remote_state.cumulus.outputs.workflow_config
  system_bucket   = local.system_bucket
  tags            = local.default_tags

  state_machine_definition = templatefile("./acme.json", {
    task_arn = aws_lambda_function.nop_lambda.arn
  })
}

resource "aws_lambda_layer_version" "lambda_dependencies" {
  filename         = "${var.DIST_DIR}/lambda_dependencies_layer.zip"
  layer_name       = "${local.prefix}-lambda_dependencies"
  source_code_hash = filebase64sha256("${var.DIST_DIR}/lambda_dependencies_layer.zip")

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
