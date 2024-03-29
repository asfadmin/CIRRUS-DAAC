cma_version = "v1.3.0"

# default bucket lists are:
# standard_bucket_names = ["private"]
# protected_bucket_names = ["protected"]
# public_bucket_names = ["public"]

# if you want to overide the default standard, protected or public bucket lists
# you can do it here
standard_bucket_names  = ["private"]
protected_bucket_names = ["protected", "protected-1"]
public_bucket_names    = ["public", "public-1"]

# example workflow bucket list
workflow_bucket_names = [
  "acme-landing",
  "acme-products",
  "acme-browse"
]

# Example of buckets we need to access, but won't create.
# These ARE NOT prefixed
partner_bucket_names = ["partner-collab-s3-bucket"]
