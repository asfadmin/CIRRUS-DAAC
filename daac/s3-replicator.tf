/* Per these Cumulus instructions

https://nasa.github.io/cumulus/docs/additional-deployment-options/share-s3-access-logs

the s3-replicator module is used to replicate access data to the metrics account.
It is only needed in accounts which are integrated with metrics, however, since
terraform doesn't have the notion of optional modules, this module defaults to
replicating from the normal internal bucket prefix to another prefix in the same
bucket

For environments which really do send info to metrics you can override the target
bucket and prefix in that environment's tfvars file.

s3_replicator_target_bucket = "metrics target bucket name"
s3_replicator_target_prefix = "metrics target prefix name"
*/


locals {
  replicator_bucket        = "${local.prefix}-internal"
  replicator_prefix        = "input/s3_access/${var.DEPLOY_NAME}${var.MATURITY}"
  replicator_target_bucket = var.s3_replicator_target_bucket == null ? local.replicator_bucket : var.s3_replicator_target_bucket
  replicator_target_prefix = var.s3_replicator_target_prefix == null ? local.replicator_prefix : var.s3_replicator_target_prefix
}

module "s3-replicator" {
  source = "https://github.com/nasa/cumulus/releases/download/v18.5.1/terraform-aws-cumulus-s3-replicator.zip"

  prefix               = local.prefix
  vpc_id               = data.aws_vpc.application_vpcs.id
  subnet_ids           = data.aws_subnets.subnet_ids.ids
  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/NGAPShRoleBoundary"
  source_bucket        = "${local.prefix}-internal"
  source_prefix        = "${local.prefix}/ems-distribution/s3-server-access-logs"
  target_bucket        = local.replicator_target_bucket
  target_prefix        = local.replicator_target_prefix
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_vpc" "application_vpcs" {
  tags = {
    Name = "Application VPC"
  }
}


data "aws_subnets" "subnet_ids" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.application_vpcs.id]
  }

  tags = {
    Name = "Private application ${data.aws_region.current.name}a subnet"
  }
}
