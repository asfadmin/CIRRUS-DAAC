locals {
  prefix = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}"

  default_tags = {
    Deployment = local.prefix
  }

  cluster_identifier = "${local.prefix}-rds-cluster"

  permissions_boundary_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/NGAPShRoleBoundary"
}
