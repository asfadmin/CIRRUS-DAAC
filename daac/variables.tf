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

variable "cma_version" {
  type = string
}

variable "dashboard_cloudfront_oai_id" {
  type    = string
  default = null
}

variable "distribution_bucket_oais" {
  type    = map(any)
  default = {}
}

variable "partner_bucket_names" {
  type    = list(string)
  default = []
}

variable "protected_bucket_names" {
  type    = list(string)
  default = ["protected"]
}

variable "public_bucket_names" {
  type    = list(string)
  default = ["public"]
}

variable "s3_replicator_target_bucket" {
  type    = string
  default = null
}

variable "s3_replicator_target_prefix" {
  type    = string
  default = null
}

variable "standard_bucket_names" {
  type    = list(string)
  default = ["private"]
}

variable "workflow_bucket_names" {
  type    = list(string)
  default = []
}
