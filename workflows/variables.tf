variable "DEPLOY_NAME" {
  type    = string
  default = "daac"
}

variable "MATURITY" {
  type    = string
  default = "dev"
}

variable "DIST_DIR" {
  type    = string
  default = "../dist"
}

variable "cloudwatch_log_retention_periods" {
  type        = map(number)
  description = "number of days logs will be retained for the respective cloudwatch log group, in the form of <module>_<cloudwatch_log_group_name>_log_retention"
  default     = {}
}
