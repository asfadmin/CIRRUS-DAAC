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
