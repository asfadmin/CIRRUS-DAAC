module "orca" {
  source = "https://github.com/nasa/cumulus-orca/releases/download/v8.1.0/cumulus-orca-terraform.zip"
  ## --------------------------
  ## Cumulus Variables
  ## --------------------------
  ## REQUIRED

  aws_region               = data.aws_region.current.name
  buckets                  = local.merged_bucket_map
  lambda_subnet_ids        = data.aws_subnets.subnet_ids.ids
  permissions_boundary_arn = local.permissions_boundary_arn
  prefix                   = local.prefix
  system_bucket            = local.system_bucket
  vpc_id                   = data.aws_vpc.application_vpcs.id

  ## OPTIONAL

  tags        = local.default_tags

  ## --------------------------
  ## ORCA Variables
  ## --------------------------
  ## REQUIRED

  db_admin_password        = local.rds_admin_login.password
  db_admin_username        = local.rds_admin_login.username
  db_host_endpoint         = local.rds_admin_login.host
  db_user_password         = var.orca_db_user_password
  dlq_subscription_email   = var.orca_dlq_subscription_email
  orca_default_bucket      = var.orca_default_bucket
  orca_reports_bucket_name = var.orca_reports_bucket
  rds_security_group_id    = data.terraform_remote_state.rds.outputs.rds_security_group_id
  s3_access_key            = var.orca_s3_access_key
  s3_secret_key            = var.orca_s3_secret_key

  ## OPTIONAL

  default_multipart_chunksize_mb                         = var.default_multipart_chunksize_mb
  metadata_queue_message_retention_time_seconds          = var.metadata_queue_message_retention_time_seconds
  orca_default_recovery_type                             = var.orca_default_recovery_type
  orca_default_storage_class                             = var.orca_default_storage_class
  orca_delete_old_reconcile_jobs_frequency_cron          = var.orca_delete_old_reconcile_jobs_frequency_cron
  orca_ingest_lambda_memory_size                         = var.orca_ingest_lambda_memory_size
  orca_ingest_lambda_timeout                             = var.orca_ingest_lambda_timeout
  orca_internal_reconciliation_expiration_days           = var.orca_internal_reconciliation_expiration_days
  orca_reconciliation_lambda_memory_size                 = var.orca_reconciliation_lambda_memory_size
  orca_reconciliation_lambda_timeout                     = var.orca_reconciliation_lambda_timeout
  orca_recovery_buckets                                  = var.orca_recovery_buckets
  orca_recovery_complete_filter_prefix                   = var.orca_recovery_complete_filter_prefix
  orca_recovery_expiration_days                          = var.orca_recovery_expiration_days
  orca_recovery_lambda_memory_size                       = var.orca_recovery_lambda_memory_size
  orca_recovery_lambda_timeout                           = var.orca_recovery_lambda_timeout
  orca_recovery_retry_limit                              = var.orca_recovery_retry_limit
  orca_recovery_retry_interval                           = var.orca_recovery_retry_interval
  orca_recovery_retry_backoff                            = var.orca_recovery_retry_backoff
  s3_inventory_queue_message_retention_time_seconds      = var.s3_inventory_queue_message_retention_time_seconds
  s3_report_frequency                                    = var.s3_report_frequency
  sqs_delay_time_seconds                                 = var.sqs_delay_time_seconds
  sqs_maximum_message_size                               = var.sqs_maximum_message_size
  staged_recovery_queue_message_retention_time_seconds   = var.staged_recovery_queue_message_retention_time_seconds
  status_update_queue_message_retention_time_seconds     = var.status_update_queue_message_retention_time_seconds
}
