data "aws_cloudfront_origin_access_identity" "distribution_cloudfront_oai" {
  for_each = toset(values(local.distribution_bucket_oais))

  id = each.key
}

data "aws_iam_policy_document" "distribution_bucket_policy_document" {
  for_each = local.distribution_bucket_oais

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

data "aws_iam_policy_document" "consolidated_distribution_bucket_policy_document" {
  for_each = local.distribution_bucket_oais
  source_policy_documents = flatten([
    aws_s3_bucket_policy.distribution_bucket_policy[each.key].policy,
    try(aws_s3_bucket_policy.allow_crud_from_consolidation["${local.prefix}-${each.key}"].policy, [])
  ])
}

resource "aws_s3_bucket_policy" "consolidated_distribution_bucket_policy" {
  for_each = data.aws_iam_policy_document.consolidated_distribution_bucket_policy_document
  bucket = "${local.prefix}-${each.key}"
  policy = each.value.json
}
