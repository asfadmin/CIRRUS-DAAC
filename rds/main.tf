resource "random_string" "admin_db_pass" {
  length  = 50
  upper   = true
  special = false
}

resource "random_string" "user_db_pass" {
  length  = 50
  upper   = true
  special = false
}

module "rds_cluster" {
  source                   = "https://github.com/nasa/cumulus/releases/download/v16.1.0-alpha.0/terraform-aws-cumulus-rds.zip"
  db_admin_username        = var.db_admin_username
  db_admin_password        = var.db_admin_password == "" ? random_string.admin_db_pass.result : var.db_admin_password
  region                   = data.aws_region.current.name
  vpc_id                   = data.aws_vpc.application_vpcs.id
  subnets                  = data.aws_subnet_ids.subnet_ids.ids
  engine_version           = var.engine_version
  parameter_group_family   = var.parameter_group_family
  deletion_protection      = var.deletion_protection
  backup_retention_period  = var.backup_retention_period
  backup_window            = var.backup_window
  cluster_identifier       = local.cluster_identifier
  tags                     = local.default_tags
  snapshot_identifier      = var.snapshot_identifier
  provision_user_database  = var.provision_user_database
  prefix                   = local.prefix
  permissions_boundary_arn = local.permissions_boundary_arn
  rds_user_password        = var.rds_user_password == "" ? random_string.user_db_pass.result : var.rds_user_password
}
