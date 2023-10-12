## Required

### Module

variable "DEPLOY_NAME" {
  type = string
}

### Orca

variable "orca_db_user_password" {
  description = "Password for RDS Orca database user authentication"
  type        = string
}

variable "orca_dlq_subscription_email" {
  type        = string
  description = "The email to notify users when messages are received in dead letter SQS queue due to orca restore failure."
  default = "test@email.com" ## TODO: Set this via secret and remove default
}

variable "orca_default_bucket" {
  type        = string
  description = "Default ORCA S3 Glacier bucket to use."
}

variable "orca_reports_bucket" {
  type        = string
  description = "ORCA Reports Bucket"
}

variable "orca_buckets" {
  type = list(string)
}

## Optional

### Module

variable "MATURITY" {
  type    = string
  default = "dev"
}

variable "elb_account_id" {
  type = string
  default = "797873946194"
}

### Orca

# See available orca docs at https://nasa.github.io/cumulus-orca/docs/developer/deployment-guide/deployment-with-cumulus#creating-cumulus-tforcatf

variable "default_multipart_chunksize_mb" {
  type        = number
  default = 250
}


variable "metadata_queue_message_retention_time_seconds" {
  type        = number
  default = 777600
}

variable "orca_default_recovery_type" {
  type        = string
  default = "Standard"
}

variable "orca_default_storage_class" {
  type        = string
  default = "GLACIER"
}

variable "orca_delete_old_reconcile_jobs_frequency_cron" {
  type        = string
  default = "cron(0 0 ? * SUN *)"
}

variable "orca_ingest_lambda_memory_size" {
  type        = number
  default = 2240
}

variable "orca_ingest_lambda_timeout" {
  type        = number
  default = 600
}

variable "orca_internal_reconciliation_expiration_days" {
  type        = number
  default = 30
}

variable "orca_reconciliation_lambda_memory_size" {
  type        = number
  default = 128
}

variable "orca_reconciliation_lambda_timeout" {
  type        = number
  default = 720
}

variable "orca_recovery_buckets" {
  type        = list(string)
  default = []
}

variable "orca_recovery_complete_filter_prefix" {
  type        = string
  default = ""
}

variable "orca_recovery_expiration_days" {
  type        = number
  default = 5
}

variable "orca_recovery_lambda_memory_size" {
  type        = number
  default = 128
}

variable "orca_recovery_lambda_timeout" {
  type        = number
  default = 720
}

variable "orca_recovery_retry_limit" {
  type        = number
  default = 3
}

variable "orca_recovery_retry_interval" {
  type        = number
  default = 1
}

variable "orca_recovery_retry_backoff" {
  type        = number
  default = 2
}

variable "s3_inventory_queue_message_retention_time_seconds" {
  type        = number
  default = 432000
}

variable "s3_report_frequency" {
  type        = string
  default = "Daily"
}

variable "sqs_delay_time_seconds" {
  type        = number
  default = 0
}

variable "sqs_maximum_message_size" {
  type        = number
  default = 262144
}

variable "staged_recovery_queue_message_retention_time_seconds" {
  type        = number
  default = 432000
}

variable "status_update_queue_message_retention_time_seconds" {
  type        = number
  default = 777600
}

variable "orca_s3_access_key" {
  type        = string
  description = "Access key for communicating with Orca S3 buckets."
  default = ""
}

variable "orca_s3_secret_key" {
  type        = string
  description = "Secret key for communicating with Orca S3 buckets."
  default = ""
}