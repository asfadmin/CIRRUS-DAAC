resource "aws_lambda_function" "atl03_extract_browse" {
  function_name    = "${local.prefix}-browse-imagery-atl03"

  filename         = "${path.module}/lambdas/lambda-browse-imagery-from-hdf5/lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/lambdas/lambda-browse-imagery-from-hdf5/lambda.zip")

  # source = "https://github.com/nsidc/lambda-browse-imagery-from-hdf5/releases/download/v0.1.1/lambda-hdf-brw.zip"

  handler          = "ingest_granule_ATL03.lambda_handler"
  role             = data.terraform_remote_state.cumulus.outputs.lambda_processing_role_arn
  runtime          = "python3.6"
  timeout          = 60

  layers = [aws_lambda_layer_version.lambda_dependencies.arn]

  // vpc_config {
  //   subnet_ids         = var.subnet_ids
  //   security_group_ids = [aws_security_group.no_ingress_all_egress.id]
  // }
}

module "discover_granules_workflow" {
  source = "https://github.com/nasa/cumulus/releases/download/v1.21.0/terraform-aws-cumulus-workflow.zip"

  prefix          = local.prefix
  name            = "DiscoverGranules"
  workflow_config = data.terraform_remote_state.cumulus.outputs.workflow_config
  system_bucket   = local.system_bucket
  // tags            = local.tags

  state_machine_definition = templatefile("./disco_grans.json", {
    disco_task_arn = data.terraform_remote_state.cumulus.outputs.discover_granules_task.task_arn
    queue_task_arn = data.terraform_remote_state.cumulus.outputs.queue_granules_task.task_arn
  })
}

module "ingest_atl03_granule_with_browse_workflow" {
  source = "https://github.com/nasa/cumulus/releases/download/v1.21.0/terraform-aws-cumulus-workflow.zip"

  prefix          = local.prefix
  name            = "IngestATL03GranuleWithBrowse"
  workflow_config = data.terraform_remote_state.cumulus.outputs.workflow_config
  system_bucket   = local.system_bucket
  // tags            = local.tags

  state_machine_definition = templatefile("./ingest.json", {
    sync_task_arn = data.terraform_remote_state.cumulus.outputs.sync_granule_task.task_arn
    processing_task_arn = aws_lambda_function.atl03_extract_browse.arn
    files_to_grans_task_arn = data.terraform_remote_state.cumulus.outputs.files_to_granules_task.task_arn
    move_task_arn = data.terraform_remote_state.cumulus.outputs.move_granules_task.task_arn
  })
}
