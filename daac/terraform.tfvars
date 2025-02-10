cma_version = "v2.0.4"

# Set up the maturity agnostic part of your bucket configuration here.
# For Example:
bucket_config_base = {
  "private"   = { type = "standard" }
  "protected" = { type = "protected" }
  "public"    = { type = "public" }
  # Workflow bucket list
  "example-browse"   = { type = "workflow" }
  "example-landing"  = { type = "workflow" }
  "example-products" = { type = "workflow" }
}

# Example partner bucket list. These ARE NOT prefixed
partner_bucket_names = ["example-partner-collab-s3-bucket"]
