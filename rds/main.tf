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
  source = "https://github.com/nasa/cumulus/releases/download/v20.0.1/terraform-aws-cumulus-rds.zip"

  backup_retention_period    = var.backup_retention_period
  backup_window              = var.backup_window
  cluster_identifier         = local.cluster_identifier
  cluster_instance_count     = var.cluster_instance_count
  db_admin_password          = var.db_admin_password == "" ? random_string.admin_db_pass.result : var.db_admin_password
  db_admin_username          = var.db_admin_username
  deletion_protection        = var.deletion_protection
  disableSSL                 = var.disableSSL
  engine_version             = var.engine_version
  lambda_memory_sizes        = var.lambda_memory_sizes
  lambda_timeouts            = var.lambda_timeouts
  max_capacity               = var.max_capacity
  min_capacity               = var.min_capacity
  parameter_group_family_v13 = var.parameter_group_family_v13
  permissions_boundary_arn   = local.permissions_boundary_arn
  prefix                     = local.prefix
  provision_user_database    = var.provision_user_database
  rds_user_password          = var.rds_user_password == "" ? random_string.user_db_pass.result : var.rds_user_password
  region                     = data.aws_region.current.name
  rejectUnauthorized         = var.rejectUnauthorized
  snapshot_identifier        = var.snapshot_identifier
  subnets                    = data.aws_subnets.subnet_ids.ids
  vpc_id                     = data.aws_vpc.application_vpcs.id

  # The RDS module defines a legacy provider configuration which preempts our
  # configuration and stops the default_tags from being applied:
  # https://bugs.earthdata.nasa.gov/browse/CUMULUS-3896
  tags = local.default_tags
}
