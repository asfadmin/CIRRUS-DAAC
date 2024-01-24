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
  type = string
}
