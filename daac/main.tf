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

  standard_bucket_names = [for n in var.standard_bucket_names : "${local.prefix}-${n}"]
  workflow_bucket_names = [for n in var.workflow_bucket_names : "${local.prefix}-${n}"]

  standard_bucket_map = { for n in var.standard_bucket_names : n => { name = "${local.prefix}-${n}", type = n } }
  workflow_bucket_map = { for n in var.workflow_bucket_names : n => { name = "${local.prefix}-${n}", type = "workflow" } }

  // creates a TEA style bucket map, is outputted via outputs.tf
  bucket_map = merge(local.standard_bucket_map, local.workflow_bucket_map)
}

resource "aws_s3_bucket" "standard-bucket" {
  for_each = toset(local.standard_bucket_names)

  bucket = each.key
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket" "workflow-bucket" {
  for_each = toset(local.workflow_bucket_names)

  bucket = each.key
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
    command = "mkdir -p tmp && curl -L -o tmp/cumulus-message-adapter.zip https://github.com/nasa/cumulus-message-adapter/releases/download/${var.cma_version}/cumulus-message-adapter.zip"
  }
}

resource "aws_s3_bucket_object" "cma" {
  depends_on  = [null_resource.CMA_release]
  bucket = aws_s3_bucket.artifacts-bucket.bucket
  key = "cumulus-message-adapter-${var.cma_version}.zip"
  source = "tmp/cumulus-message-adapter.zip"
}

resource "aws_lambda_layer_version" "cma_layer" {
  s3_bucket = aws_s3_bucket.artifacts-bucket.bucket
  s3_key = aws_s3_bucket_object.cma.key
  layer_name = "${local.prefix}-CMA-layer"
}
