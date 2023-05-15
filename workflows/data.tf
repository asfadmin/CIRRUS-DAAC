data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "terraform_remote_state" "cumulus" {
  backend   = "s3"
  workspace = var.DEPLOY_NAME
  config    = local.cumulus_remote_state_config
}
