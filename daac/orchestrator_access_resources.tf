variable tenant_account_id_bucket_mapping {
  type = map(list(string))
}

resource "aws_s3_access_point" "tenant_bucket_access" {
  for_each = merge(flatten([
      for account_id, buckets in var.tenant_account_id_bucket_mapping : {
        for bucket in buckets :  bucket => account_id
      }
    ]
  )...)
  # for_each = [{bucket_name='ob-cumulus-sit-private', id="12345"}]
  bucket = each.key
  name = "${each.key}-access-point"
  bucket_account_id = each.value
}

resource "aws_s3control_access_point_policy" "tenant_ap_policy" {
  for_each = aws_s3_access_point.tenant_bucket_access
  access_point_arn = each.value.arn
  policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:ListBucket"
        ]
        Principal = {
          AWS = data.aws_caller_identity.current.account_id
        }
        Resource = [
          "${each.value.arn}/object/*",
          "${each.value.arn}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:DeleteObject"
        ]
        Principal = {
          AWS = data.aws_caller_identity.current.account_id
        }
        Resource = [
          "${each.value.arn}/object/*"
        ]
      }
    ]
  })
}