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

module "hello_world_workflow" {
  source = "https://github.com/nasa/cumulus/releases/download/v1.17.0/terraform-aws-cumulus-workflow.zip"

  prefix                   = local.prefix
  name                     = "HelloWorldWorkflow"
  workflow_config          = data.terraform_remote_state.cumulus.outputs.workflow_config
  system_bucket            = local.system_bucket
  tags                     = local.default_tags

  state_machine_definition = templatefile("./hello_world_workflow.json", {
    task_arn = data.terraform_remote_state.cumulus.outputs.hello_world_task.task_arn
  })
}

locals {
  prefix = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}"
  system_bucket = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}-internal"
  default_tags = {
    Deployment = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}"
  }

  cumulus_remote_state_config = {
    bucket = "cumulus-${var.MATURITY}-tf-state"
    key    = "cumulus/terraform.tfstate"
    region = "${data.aws_region.current.name}"
  }
}

data "aws_region" "current" {}

data "terraform_remote_state" "cumulus" {
  backend = "s3"
  workspace = "${var.DEPLOY_NAME}"
  config  = local.cumulus_remote_state_config
}
