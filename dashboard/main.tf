terraform {
  required_providers {
    aws  = "~> 2.46.0"
    null = "~> 2.1.0"
  }
  backend "s3" {
  }
}

provider "aws" {
}

locals {
  prefix = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}"
}

resource "aws_s3_bucket" "dashboard-bucket" {
  bucket = "${local.prefix}-dashboard"
}