resource "aws_s3_bucket_policy" "allow_crud_from_consolidation" {
  for_each = var.consolidation_acct_id != null ? merge(
    aws_s3_bucket.public-bucket,
    aws_s3_bucket.standard-bucket,
    aws_s3_bucket.protected-bucket,
    aws_s3_bucket.workflow-bucket
  ) : {}
  bucket = each.key
  policy = jsonencode({

    Version = "2012-10-17",
    Statement = [
      {
        Sid = "${each.key}-CrossAccountReadAccess",
        Effect =  "Allow"
        Principal = {
          AWS = local.consolidation_crud_roles
        },

        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket"
        ],

        Resource = [
          each.value.arn,
          "${each.value.arn}/*"
        ]
      },
      {
        Sid = "${each.key}-CrossAccountWriteAccess",
        Effect =  "Allow"
        Principal = {
          AWS = local.consolidation_crud_roles
        },

        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:DeleteObject"
        ],

        Resource = [
          "${each.value.arn}/*"
        ]
      },
    ]
  })
}
