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
  type        = string
  description = "Cumulus Message Adapter release version from https://github.com/nasa/cumulus-message-adapter/releases."
}

variable "dashboard_cloudfront_oai_id" {
  type        = string
  default     = null
  description = "CloudFront OAI ID to use for dashboard bucket policy."
}

variable "distribution_bucket_oais" {
  type        = map(string)
  default     = {}
  description = "A map of bucket names to CloudFront OAI IDs. The OAI IDs will be added to the bucket policy to allow data distribution via CloudFront for those buckets."
}

variable "partner_bucket_names" {
  type        = list(string)
  default     = []
  description = "List of buckets which we need access to but do not create. Include the full bucket name."
}

variable "protected_bucket_names" {
  type        = list(string)
  default     = []
  description = "List of 'protected' buckets to create. The stack prefix is automatically added to the bucket names."
}

variable "public_bucket_names" {
  type        = list(string)
  default     = []
  description = "List of 'public' buckets to create. The stack prefix is automatically added to the bucket names."
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

variable "standard_bucket_names" {
  type        = list(string)
  default     = []
  description = "List of 'standard' buckets to create. The stack prefix is automatically added to the bucket names."
}

variable "workflow_bucket_names" {
  type        = list(string)
  default     = []
  description = "List of 'workflow' buckets to create. The stack prefix is automatically added to the bucket names."
}
