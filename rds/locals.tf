locals {
  prefix = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}"

  default_tags = {
    Deployment = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}"
  }

  cluster_identifier = "${local.prefix}-rds-cluster"

  permissions_boundary_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/NGAPShRoleBoundary"
}
