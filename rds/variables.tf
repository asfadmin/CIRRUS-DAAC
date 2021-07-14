variable "DEPLOY_NAME" {
  type = string
}

variable "MATURITY" {
  type = string
  default = "dev"
}

variable "db_admin_username" {
  description = "Username for RDS database authentication"
  type = string
  default = "cumulus_admin"
}

variable "db_admin_password" {
  description = "Password for RDS database authentication"
  type = string
  default = ""
}

variable "deletion_protection" {
  description = "Flag to prevent terraform from making changes that delete the database in CI"
  type        = bool
  default     = true
}

variable "snapshot_identifier" {
  description = "Optional database snapshot for restoration"
  type = string
  default = null
}

variable "engine_version" {
  description = "Postgres engine version for Serverless cluster"
  type        = string
  default     = "10.12"
}

### Required for user/database provisioning
variable "provision_user_database" {
  description = "true/false flag to configure if the module should provision a user and database using default settings"
  type = bool
  default = true
}

variable "rds_user_password" {
  type    = string
  default = ""
}
