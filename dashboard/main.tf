terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.75.2"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 2.1"
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
}

resource "aws_s3_bucket" "dashboard-bucket" {
  bucket = "${local.prefix}-dashboard"
}