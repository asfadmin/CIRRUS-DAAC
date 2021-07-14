terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.14.1"
    }

    random = {
      source = "hashicorp/random"
    }

  }

  backend "s3" {
  }

}

provider "aws" {
  ignore_tags {
    key_prefixes = ["gsfc-ngap"]
  }
}

locals {
  prefix = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}"

  default_tags = {
    Deployment = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}"
  }

  cluster_identifier = "${local.prefix}-rds-cluster"

  permissions_boundary_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/NGAPShRoleBoundary"
}

resource "random_string" "admin_db_pass" {
  length  = 50
  upper   = true
  special = false
}

resource "random_string" "user_db_pass" {
  length  = 50
  upper   = true
  special = false
}

module "rds_cluster" {
  source = "https://github.com/nasa/cumulus/releases/download/v9.2.0/terraform-aws-cumulus-rds.zip"
  db_admin_username        = var.db_admin_username
  db_admin_password        = var.db_admin_password == "" ? random_string.admin_db_pass.result : var.db_admin_password
  region                   = data.aws_region.current.name
  vpc_id                   = data.aws_vpc.application_vpcs.id
  subnets                  = data.aws_subnet_ids.subnet_ids.ids
  engine_version           = var.engine_version
  deletion_protection      = var.deletion_protection
  cluster_identifier       = local.cluster_identifier
  tags                     = local.default_tags
  snapshot_identifier      = var.snapshot_identifier
  provision_user_database  = var.provision_user_database
  prefix                   = local.prefix
  permissions_boundary_arn = local.permissions_boundary_arn
  rds_user_password        = var.rds_user_password == "" ? random_string.user_db_pass.result : var.rds_user_password
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_vpc" "application_vpcs" {
  tags = {
    Name = "Application VPC"
  }
}

data "aws_subnet_ids" "subnet_ids" {
  vpc_id = data.aws_vpc.application_vpcs.id

  filter {
    name   = "tag:Name"
    values = ["Private application ${data.aws_region.current.name}a subnet",
              "Private application ${data.aws_region.current.name}b subnet"]
  }
}
