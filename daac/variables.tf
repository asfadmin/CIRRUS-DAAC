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
  default = ["private"]
}

variable "protected_bucket_names" {
  type = list(string)
  default = ["protected"]
}

variable "public_bucket_names" {
  type = list(string)
  default = ["public"]
}

variable "workflow_bucket_names" {
  type = list(string)
  default = []
}
