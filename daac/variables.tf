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

variable "bucket_config" {
  type = map(object({
    # NOTE: Type cannot be overridden for buckets. It only exists here to allow
    # additional buckets to be defined for a specific maturity only.
    type = optional(string)
    oai  = optional(string)
  }))
  default     = {}
  description = "Maturity specific overrides for the base bucket config."
}

# type = {"standard", "protected", "public", "workflow"}
# oai - The OAI ID will be added to the bucket policy to allow data distribution via CloudFront for this bucket.
variable "bucket_config_base" {
  type = map(object({
    type = string
    oai  = optional(string)
  }))
  default     = {}
  description = "Map of buckets to create. Each bucket has a config that can be used to set the bucket type and enable extra features on the bucket. Add new features here as necessary."
}

variable "cma_version" {
  type        = string
  description = "Cumulus Message Adapter release version from https://github.com/nasa/cumulus-message-adapter/releases."
}

variable "dashboard_cloudfront_oai_id" {
  type        = string
  default     = null
  description = "CloudFront OAI ID to use for dashboard bucket policy."
}

variable "partner_bucket_names" {
  type        = list(string)
  default     = []
  description = "List of buckets which we need access to but do not create. Include the full bucket name."
}

variable "s3_replicator_target_bucket" {
  type        = string
  default     = null
  description = "Bucket that the S3 replicator will write logs to."
}

variable "s3_replicator_target_prefix" {
  type        = string
  default     = null
  description = "Prefix that the S3 replicator will write logs to in the target bucket."
}
