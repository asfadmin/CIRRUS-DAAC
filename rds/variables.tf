variable "CIRRUS_CORE_VERSION" {
  type        = string
  description = "The version of the CIRRUS-core repository. It is set in the CIRRUS-core Makefile and passed to the docker container."
}

variable "CIRRUS_DAAC_VERSION" {
  type        = string
  description = "The version of the CIRRUS-DAAC repository. It is set in the CIRRUS-core Makefile and passed to the docker container."
}

variable "DEPLOY_NAME" {
  type = string
}

variable "MATURITY" {
  type    = string
  default = "dev"
}

variable "backup_retention_period" {
  description = "Number of backup periods to retain"
  type        = number
  default     = 1
}

variable "backup_window" {
  description = "Preferred database backup window (UTC)"
  type        = string
  default     = "07:00-09:00"
}

variable "db_admin_password" {
  description = "Password for RDS database authentication"
  type        = string
  default     = ""
}

variable "db_admin_username" {
  description = "Username for RDS database authentication"
  type        = string
  default     = "cumulus_admin"
}

variable "deletion_protection" {
  description = "Flag to prevent terraform from making changes that delete the database in CI"
  type        = bool
  default     = true
}

variable "engine_version" {
  description = "Postgres engine version for Serverless cluster"
  type        = string
  default     = "11.13"
}

variable "parameter_group_family" {
  description = "Database family to use for creating database parameter group"
  type        = string
  default     = "aurora-postgresql11"
}

### Required for user/database provisioning
variable "provision_user_database" {
  description = "true/false flag to configure if the module should provision a user and database using default settings"
  type        = bool
  default     = true
}


variable "rds_user_password" {
  type    = string
  default = ""
}

variable "snapshot_identifier" {
  description = "Optional database snapshot for restoration"
  type        = string
  default     = null
}
