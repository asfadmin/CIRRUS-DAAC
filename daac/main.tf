resource "aws_s3_bucket" "standard-bucket" {
  for_each = toset(local.standard_bucket_names)

  bucket = each.key
  lifecycle {
    prevent_destroy = true
  }
  tags = local.dar_yes_tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "standard_bucket_encryption_configuration" {
  for_each = toset(local.standard_bucket_names)

  bucket = each.key

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#For EMS reporting, buckets which are exposed by TEA need to have server access
# logging enabled.  The Cumulus standard is for the logs to be added to the
# "internal" bucket.  An acl is added to this bucket
#  This is documented more fully in:
#  https://nasa.github.io/cumulus/docs/deployment/server_access_logging

resource "aws_s3_bucket" "internal-bucket" {
  bucket = "${local.prefix}-internal"
  lifecycle {
    prevent_destroy = true
  }
  tags = local.dar_yes_tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "internal_bucket_encryption_configuration" {
  bucket = aws_s3_bucket.internal-bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "internal-bucket" {
  bucket = aws_s3_bucket.internal-bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "internal-bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.internal-bucket]
  bucket     = aws_s3_bucket.internal-bucket.id
  acl        = "log-delivery-write"
}

# protected buckets log to "internal"
resource "aws_s3_bucket" "protected-bucket" {
  # protected buckets defined in variables.tf
  for_each = toset(local.protected_bucket_names)
  bucket   = each.key
  lifecycle {
    prevent_destroy = true
  }
  tags = local.dar_no_tags
}

resource "aws_s3_bucket_logging" "protected_bucket_logging" {
  for_each = toset(local.protected_bucket_names)
  bucket = each.key
  target_bucket = "${local.prefix}-internal"
  target_prefix = "${local.prefix}/ems-distribution/s3-server-access-logs/"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "protected_bucket_encryption_configuration" {
  for_each = toset(local.protected_bucket_names)

  bucket = each.key

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# public buckets log to "internal"
resource "aws_s3_bucket" "public-bucket" {
  # public buckets defined in variables.tf
  for_each = toset(local.public_bucket_names)
  bucket   = each.key
  lifecycle {
    prevent_destroy = true
  }
  tags = local.dar_no_tags
}

resource "aws_s3_bucket_logging" "public_bucket_logging" {
  for_each = toset(local.public_bucket_names)
  bucket = each.key
  target_bucket = "${local.prefix}-internal"
  target_prefix = "${local.prefix}/ems-distribution/s3-server-access-logs/"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "public_bucket_encryption_configuration" {
  for_each = toset(local.public_bucket_names)

  bucket = each.key

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket" "workflow-bucket" {
  for_each = toset(local.workflow_bucket_names)

  bucket = each.key
  lifecycle {
    prevent_destroy = true
  }
  tags = local.dar_yes_tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "workflow_bucket_encryption_configuration" {
  for_each = toset(local.workflow_bucket_names)

  bucket = each.key

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket" "artifacts-bucket" {
  bucket = "${local.prefix}-artifacts"
  lifecycle {
    prevent_destroy = true
  }
  tags = local.dar_yes_tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts_bucket_encryption_configuration" {
  bucket = aws_s3_bucket.artifacts-bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "null_resource" "CMA_release" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "mkdir -p tmp && curl -L -o tmp/cumulus-message-adapter.zip https://github.com/nasa/cumulus-message-adapter/releases/download/${var.cma_version}/cumulus-message-adapter.zip"
  }
}

resource "aws_s3_object" "cma" {
  depends_on = [null_resource.CMA_release]
  bucket     = aws_s3_bucket.artifacts-bucket.bucket
  key        = "cumulus-message-adapter-${var.cma_version}.zip"
  source     = "tmp/cumulus-message-adapter.zip"
}

resource "aws_lambda_layer_version" "cma_layer" {
  s3_bucket  = aws_s3_bucket.artifacts-bucket.bucket
  s3_key     = aws_s3_object.cma.key
  layer_name = "${local.prefix}-CMA-layer"
}

/*
If you would like to deploy a custom tea bucket map you can uncomment this resource
and rename and modify the bucket_map.yaml.tmpl.sample file
*/
/*
resource "aws_s3_object" "tea_bucket_map" {
  bucket = aws_s3_bucket.internal-bucket.bucket
  key     = "${local.prefix}/thin-egress-app/${local.prefix}-daac_bucket_map.yaml"
  content = templatefile("./bucket_map.yaml.tmpl", { protected_buckets = local.protected_bucket_names, public_buckets = local.public_bucket_names })
  etag    = md5(templatefile("./bucket_map.yaml.tmpl", { protected_buckets = local.protected_bucket_names, public_buckets = local.public_bucket_names }))
}
*/
