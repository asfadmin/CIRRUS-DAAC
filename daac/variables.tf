variable "DEPLOY_NAME" {
  type = string
}

variable "MATURITY" {
  type = string
  default = "dev"
}

variable "cma_version" {
  type = string
}

variable "standard_bucket_names" {
  type = list(string)
  default = ["internal", "private", "protected", "public"]
}

variable "workflow_bucket_names" {
  type = list(string)
  default = []
}
