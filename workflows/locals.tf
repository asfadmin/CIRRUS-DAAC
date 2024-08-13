locals {
  prefix        = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}"
  system_bucket = "${local.prefix}-internal"
  default_tags = {
    Deployment = local.prefix
  }

  cumulus_remote_state_config = {
    bucket = "${local.prefix}-tf-state-${substr(data.aws_caller_identity.current.account_id, -4, 4)}"
    key    = "cumulus/terraform.tfstate"
    region = data.aws_region.current.name
  }

  python_version = "python3.9"
}
