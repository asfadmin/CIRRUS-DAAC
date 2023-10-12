## --------------------------
## Database configuration
## --------------------------

## TODO - Decide if it's valueable to allow for an alternate cluster to the rds module cluster
## OBDAAC implementation makes it YAGNI
data "aws_secretsmanager_secret" "rds_admin_credentials" {
  arn =  data.terraform_remote_state.rds.outputs.admin_db_login_secret_arn
}

data "aws_secretsmanager_secret_version" "rds_admin_credentials" {
  secret_id = data.aws_secretsmanager_secret.rds_admin_credentials.id
}


## --------------------------
## AWS configuration
## --------------------------

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}


data "aws_subnets" "subnet_ids" {
  filter {
    name = "tag:Name"
    values = ["Private application ${data.aws_region.current.name}a subnet",
    "Private application ${data.aws_region.current.name}b subnet"]
  }
}

data "aws_vpc" "application_vpcs" {
  tags = {
    Name = "Application VPC"
  }
}

## --------------------------
## Remote state configuration
## --------------------------

data "terraform_remote_state" "rds" {
  backend   = "s3"
  workspace = var.DEPLOY_NAME
  config    = local.rds_remote_state_config
}

data "terraform_remote_state" "daac" {
  backend   = "s3"
  workspace = var.DEPLOY_NAME
  config    = local.daac_remote_state_config
}
