output "cirrus_core_version" {
  value = var.CIRRUS_CORE_VERSION
}

output "cirrus_daac_version" {
  value = var.CIRRUS_DAAC_VERSION
}

output "rds_security_group_id" {
  value = module.rds_cluster.security_group_id
}

output "rds_endpoint" {
  value = module.rds_cluster.rds_endpoint
}

output "admin_db_login_secret_arn" {
  value = module.rds_cluster.admin_db_login_secret_arn
}

output "admin_db_login_secret_version" {
  value = module.rds_cluster.admin_db_login_secret_version
}

output "rds_user_access_secret_arn" {
  value = module.rds_cluster.user_credentials_secret_arn
}
