locals {
  default_tags = {
    Deployment = local.prefix
  }
  ## TODO - These should probably be module outputs from Cirrus rather than convention
  system_bucket = data.terraform_remote_state.daac.outputs.bucket_map.internal.name

  prefix = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}"
  rds_remote_state_config = {
    bucket = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}-tf-state-${substr(data.aws_caller_identity.current.account_id, -4, 4)}"
    key    = "rds/terraform.tfstate"
    region = data.aws_region.current.name
  }
  daac_remote_state_config = {
    bucket = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}-tf-state-${substr(data.aws_caller_identity.current.account_id, -4, 4)}"
    key    = "daac/terraform.tfstate"
    region = data.aws_region.current.name
  }
  rds_admin_login = jsondecode(data.aws_secretsmanager_secret_version.rds_admin_credentials.secret_string)
  permissions_boundary_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/NGAPShRoleBoundary"
  daac_bucket_map = data.terraform_remote_state.daac.outputs.bucket_map
  merged_bucket_map = merge(local.daac_bucket_map, { for n in var.orca_buckets : n => { name = n, type = "orca"} })
}
