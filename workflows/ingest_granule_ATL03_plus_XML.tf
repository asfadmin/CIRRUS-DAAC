

// Add XMLTransform - Transform ISO XML to CMR ISO XML
resource "aws_lambda_function" "XMLTransform" {
  function_name    = "${local.prefix}-XMLTransform"

  #filename         = "${path.module}/lambdas/XMLTransform/lambda.zip"
  #source_code_hash = filebase64sha256("${path.module}/lambdas/XMLTransform/lambda.zip")

  source = https://github.com/nsidc/XMLTransform_ISO_to_CMR_Local/releases/download/0.1.0/Lambda.zip

  handler          = "XMLTransform.lambda_handler"
  role             = data.terraform_remote_state.cumulus.outputs.lambda_processing_role_arn
  runtime          = "python3.8"
  timeout          = 60

  layers = [aws_lambda_layer_version.lambda_dependencies.arn]

}


module "ingest_atl03_granule_with_browse_and_xml_workflow" {
  source = "https://github.com/nasa/cumulus/releases/download/v1.22.1/terraform-aws-cumulus-workflow.zip"

  prefix          = local.prefix
  name            = "IngestATL03GranuleWithBrowse"
  workflow_config = data.terraform_remote_state.cumulus.outputs.workflow_config
  system_bucket   = local.system_bucket
  // tags            = local.tags

  state_machine_definition = templatefile("./ingest.json", {
    sync_task_arn = data.terraform_remote_state.cumulus.outputs.sync_granule_task.task_arn
    processing_browse_task_arn = aws_lambda_function.atl03_extract_browse.arn
    processing_xml_task_arn = aws_lambda_function.XMLTransform.arn
    files_to_grans_task_arn = data.terraform_remote_state.cumulus.outputs.files_to_granules_task.task_arn
    move_task_arn = data.terraform_remote_state.cumulus.outputs.move_granules_task.task_arn
  })
}
