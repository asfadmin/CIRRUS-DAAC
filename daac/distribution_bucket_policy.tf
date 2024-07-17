data "aws_cloudfront_origin_access_identity" "distribution_cloudfront_oai" {
  for_each = toset(values(var.distribution_bucket_oais))

  id = each.key
}

data "aws_iam_policy_document" "distribution_bucket_policy_document" {
  for_each = var.distribution_bucket_oais

  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${local.prefix}-${each.key}/*"]

    principals {
      type = "AWS"
      identifiers = [
        data.aws_cloudfront_origin_access_identity.distribution_cloudfront_oai[each.value].iam_arn
      ]
    }
  }

  # Need ListBucket permissions so that missing keys will return 404 errors instead of 403
  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${local.prefix}-${each.key}"]

    principals {
      type = "AWS"
      identifiers = [
        data.aws_cloudfront_origin_access_identity.distribution_cloudfront_oai[each.value].iam_arn
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "distribution_bucket_policy" {
  for_each = var.distribution_bucket_oais

  bucket = "${local.prefix}-${each.key}"
  policy = try(data.aws_iam_policy_document.distribution_bucket_policy_document[each.key].json, null)
}
