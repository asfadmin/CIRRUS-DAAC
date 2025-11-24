resource "aws_s3_bucket_policy" "standard_cross_acoount_access" {
  for_each = var.consolidation_acct_id != null ? aws_s3_bucket.standard-bucket : {}
  bucket = each.key
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "CrossAccountReadAccessEcs"
        Effect = "allow"
        Principal = {
          AWS = "arn:aws:iam::${var.consolidation_acct_id}:role/${var.consolidation_deploy_name}-cumulus-${local.consolidation_maturity}_ecs_cluster_instance_role"
        }
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket"
        ]
        Resource = [
          "${each.value.arn}",
          "${each.value.arn}/*"
        ]
      },
      {
        Sid = "CrossAccountReadAccessEcs"
        Effect = "allow"
        Principal = {
          AWS = "arn:aws:iam::${var.consolidation_acct_id}:role/${var.consolidation_deploy_name}-cumulus-${local.consolidation_maturity}-lambda-processing"
        }
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket"
        ]
        Resource = [
          "${each.value.arn}",
          "${each.value.arn}/*"
        ]
      },
      {
        Sid = "CrossAccountWriteAccessEcs",
        Effect = "Allow",
        Principal = {
            AWS = "arn:aws:iam::${var.consolidation_acct_id}:role/${var.consolidation_deploy_name}-cumulus-${local.consolidation_maturity}_ecs_cluster_instance_role"
        },
        Action = [
            "s3:PutObject",
            "s3:PutObjectAcl",
            "s3:DeleteObject"
        ],
        Resource = "${each.value.arn}/*"
      },
      {
        Sid = "CrossAccountWriteAccessLambda",
        Effect = "Allow",
        Principal = {
            AWS = "arn:aws:iam::${var.consolidation_acct_id}:role/${var.consolidation_deploy_name}-cumulus-${local.consolidation_maturity}-lambda-processing"
        },
        Action = [
            "s3:PutObject",
            "s3:PutObjectAcl",
            "s3:DeleteObject"
        ],
        Resource = "${each.value.arn}/*"
      },
    ]
  })
}

resource "aws_s3_bucket_policy" "public_cross_acoount_access" {
  for_each = var.consolidation_acct_id != null ? aws_s3_bucket.public-bucket : {}
  bucket = each.key
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "CrossAccountReadAccessEcs"
        Effect = "allow"
        Principal = {
          AWS = "arn:aws:iam::${var.consolidation_acct_id}:role/${var.consolidation_deploy_name}-cumulus-${local.consolidation_maturity}_ecs_cluster_instance_role"
        }
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket"
        ]
        Resource = [
          "${each.value.arn}",
          "${each.value.arn}/*"
        ]
      },
      {
        Sid = "CrossAccountReadAccessEcs"
        Effect = "allow"
        Principal = {
          AWS = "arn:aws:iam::${var.consolidation_acct_id}:role/${var.consolidation_deploy_name}-cumulus-${local.consolidation_maturity}-lambda-processing"
        }
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket"
        ]
        Resource = [
          "${each.value.arn}",
          "${each.value.arn}/*"
        ]
      },
      {
        Sid = "CrossAccountWriteAccessEcs",
        Effect = "Allow",
        Principal = {
            AWS = "arn:aws:iam::${var.consolidation_acct_id}:role/${var.consolidation_deploy_name}-cumulus-${local.consolidation_maturity}_ecs_cluster_instance_role"
        },
        Action = [
            "s3:PutObject",
            "s3:PutObjectAcl",
            "s3:DeleteObject"
        ],
        Resource = "${each.value.arn}/*"
      },
      {
        Sid = "CrossAccountWriteAccessLambda",
        Effect = "Allow",
        Principal = {
            AWS = "arn:aws:iam::${var.consolidation_acct_id}:role/${var.consolidation_deploy_name}-cumulus-${local.consolidation_maturity}-lambda-processing"
        },
        Action = [
            "s3:PutObject",
            "s3:PutObjectAcl",
            "s3:DeleteObject"
        ],
        Resource = "${each.value.arn}/*"
      },
    ]
  })
}

resource "aws_s3_bucket_policy" "protected_cross_acoount_access" {
  for_each = var.consolidation_acct_id != null ? aws_s3_bucket.protected-bucket : {}
  bucket = each.key
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "CrossAccountReadAccessEcs"
        Effect = "allow"
        Principal = {
          AWS = "arn:aws:iam::${var.consolidation_acct_id}:role/${var.consolidation_deploy_name}-cumulus-${local.consolidation_maturity}_ecs_cluster_instance_role"
        }
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket"
        ]
        Resource = [
          "${each.value.arn}",
          "${each.value.arn}/*"
        ]
      },
      {
        Sid = "CrossAccountReadAccessEcs"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.consolidation_acct_id}:role/${var.consolidation_deploy_name}-cumulus-${local.consolidation_maturity}-lambda-processing"
        }
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket"
        ]
        Resource = [
          "${each.value.arn}",
          "${each.value.arn}/*"
        ]
      },
      {
        Sid = "CrossAccountWriteAccessEcs",
        Effect = "Allow",
        Principal = {
            AWS = "arn:aws:iam::${var.consolidation_acct_id}:role/${var.consolidation_deploy_name}-cumulus-${local.consolidation_maturity}_ecs_cluster_instance_role"
        },
        Action = [
            "s3:PutObject",
            "s3:PutObjectAcl",
            "s3:DeleteObject"
        ],
        Resource = "${each.value.arn}/*"
      },
      {
        Sid = "CrossAccountWriteAccessLambda",
        Effect = "Allow",
        Principal = {
            AWS = "arn:aws:iam::${var.consolidation_acct_id}:role/${var.consolidation_deploy_name}-cumulus-${local.consolidation_maturity}-lambda-processing"
        },
        Action = [
            "s3:PutObject",
            "s3:PutObjectAcl",
            "s3:DeleteObject"
        ],
        Resource = "${each.value.arn}/*"
      },
    ]
  })
}

resource "aws_s3_bucket_policy" "workflow_bucket_cross_acoount_access" {
  for_each = var.consolidation_acct_id != null ? aws_s3_bucket.workflow-bucket : {}
  bucket = each.key
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "CrossAccountReadAccessEcs"
        Effect = "allow"
        Principal = {
          AWS = "arn:aws:iam::${var.consolidation_acct_id}:role/${var.consolidation_deploy_name}-cumulus-${local.consolidation_maturity}_ecs_cluster_instance_role"
        }
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket"
        ]
        Resource = [
          "${each.value.arn}",
          "${each.value.arn}/*"
        ]
      },
      {
        Sid = "CrossAccountReadAccessEcs"
        Effect = "allow"
        Principal = {
          AWS = "arn:aws:iam::${var.consolidation_acct_id}:role/${var.consolidation_deploy_name}-cumulus-${local.consolidation_maturity}-lambda-processing"
        }
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket"
        ]
        Resource = [
          "${each.value.arn}",
          "${each.value.arn}/*"
        ]
      },
      {
        Sid = "CrossAccountWriteAccessEcs",
        Effect = "Allow",
        Principal = {
            AWS = "arn:aws:iam::${var.consolidation_acct_id}:role/${var.consolidation_deploy_name}-cumulus-${local.consolidation_maturity}_ecs_cluster_instance_role"
        },
        Action = [
            "s3:PutObject",
            "s3:PutObjectAcl",
            "s3:DeleteObject"
        ],
        Resource = "${each.value.arn}/*"
      },
      {
        Sid = "CrossAccountWriteAccessLambda",
        Effect = "Allow",
        Principal = {
            AWS = "arn:aws:iam::${var.consolidation_acct_id}:role/${var.consolidation_deploy_name}-cumulus-${local.consolidation_maturity}-lambda-processing"
        },
        Action = [
            "s3:PutObject",
            "s3:PutObjectAcl",
            "s3:DeleteObject"
        ],
        Resource = "${each.value.arn}/*"
      },
    ]
  })
}