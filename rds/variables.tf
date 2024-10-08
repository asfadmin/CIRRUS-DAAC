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

variable "auto_pause" {
  description = "Determines if the RDS cluster should automatically pause after a period of inactivity"
  type        = bool
  default     = true
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

variable "enable_upgrade" {
  description = "Flag to enable use of updated parameter group for postgres v13"
  type        = bool
  default     = true
}

variable "engine_version" {
  description = "Postgres engine version for serverless cluster"
  type        = string
  default     = "13.12"
}

variable "parameter_group_family" {
  description = "Database family to use for creating database parameter group"
  type        = string
  default     = "aurora-postgresql11"
}

variable "parameter_group_family_v13" {
  description = "Database family to use for creating database parameter group under postgres 13 upgrade conditions"
  type        = string
  default     = "aurora-postgresql13"
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

variable "seconds_until_auto_pause" {
  description = "Number of seconds of inactivity before RDS cluster is paused"
  type        = number
  default     = 300
}

variable "snapshot_identifier" {
  description = "Optional database snapshot for restoration"
  type        = string
  default     = null
}
