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

resource "aws_s3_bucket" "cumulus-internal-bucket" {
  bucket = "${local.prefix}-internal"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket" "artifacts-bucket" {
  bucket = "${local.prefix}-artifacts"
  lifecycle {
    prevent_destroy = true
  }
}

resource "null_resource" "CMA_release" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "curl -L -o ../tmp/cumulus-message-adapter.zip https://github.com/nasa/cumulus-message-adapter/releases/download/${var.cma_version}/cumulus-message-adapter.zip"
  }
}

resource "aws_s3_bucket_object" "cma" {
  depends_on  = [null_resource.CMA_release]
  bucket = aws_s3_bucket.artifacts-bucket.bucket
  key = "cumulus-message-adapter-${var.cma_version}.zip"
  source = "../tmp/cumulus-message-adapter.zip"
}

resource "aws_lambda_layer_version" "cma_layer" {
  s3_bucket = aws_s3_bucket.artifacts-bucket.bucket
  s3_key = aws_s3_bucket_object.cma.key
  layer_name = "${local.prefix}-CMA-layer"
}
