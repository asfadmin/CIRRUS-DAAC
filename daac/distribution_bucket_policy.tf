data "aws_cloudfront_origin_access_identity" "distribution_cloudfront_oai" {
  for_each = toset(values(local.distribution_bucket_oais))

  id = each.key
}

resource "aws_s3_bucket_policy" "distribution_bucket_policy" {
  for_each = local.distribution_bucket_oais
  bucket = each.key
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = concat(try(jsondecode(aws_s3_bucket_policy.allow_crud_from_consolidation[each.key].policy).Statement, []), [
      {
        Sid = "${each.key}-DistributionPolicyGet"
        Effect = "Allow"
        Action   = ["s3:GetObject"]
        Resource = ["arn:aws:s3:::${each.key}/*"]

        Principal =  {
          AWS = data.aws_cloudfront_origin_access_identity.distribution_cloudfront_oai[each.value].iam_arn
        }
      },
      {
        Sid = "${each.key}-DistributionPolicyList"
        Effect = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = ["arn:aws:s3:::${each.key}"]

        Principal =  {
          AWS = data.aws_cloudfront_origin_access_identity.distribution_cloudfront_oai[each.value].iam_arn
        }
      }
    ])
  })
}
