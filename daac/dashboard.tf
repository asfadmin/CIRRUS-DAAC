resource "aws_s3_bucket" "dashboard_bucket" {
  bucket = "${local.prefix}-dashboard"

  lifecycle {
    prevent_destroy = true
  }

  tags = local.default_tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "dashboard_encryption_configuration" {
  bucket = aws_s3_bucket.dashboard_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#
# The following resources are all optional based on the value of
#   var.dashboard_cloudfront_oai_id
#
data "aws_cloudfront_origin_access_identity" "dashboard_cloudfront_oai" {
  count = var.dashboard_cloudfront_oai_id == null ? 0 : 1

  id = var.dashboard_cloudfront_oai_id
}

data "aws_iam_policy_document" "dashboard_bucket_policy_document" {
  count = var.dashboard_cloudfront_oai_id == null ? 0 : 1

  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.dashboard_bucket.arn}/*"]

    principals {
      type = "AWS"
      identifiers = [
        for distribution in data.aws_cloudfront_origin_access_identity.dashboard_cloudfront_oai : distribution.iam_arn
      ]
    }
  }

  # Need ListBucket permissions so that missing keys will return 404 errors instead of 403
  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.dashboard_bucket.arn]

    principals {
      type = "AWS"
      identifiers = [
        for distribution in data.aws_cloudfront_origin_access_identity.dashboard_cloudfront_oai : distribution.iam_arn
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "dashboard_bucket_policy" {
  count = var.dashboard_cloudfront_oai_id == null ? 0 : 1

  bucket = aws_s3_bucket.dashboard_bucket.id
  policy = try(data.aws_iam_policy_document.dashboard_bucket_policy_document[0].json, null)
}
