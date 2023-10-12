locals {
    default_tags = {
        Deployment = local.prefix
    }
    prefix = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}"
    daac_remote_state_config = {
        bucket = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}-tf-state-${substr(data.aws_caller_identity.current.account_id, -4, 4)}"
        key    = "daac/terraform.tfstate"
        region = data.aws_region.current.name
    }
    cumulus_remote_state_config = {
        bucket = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}-tf-state-${substr(data.aws_caller_identity.current.account_id, -4, 4)}"
        key    = "cumulus/terraform.tfstate"
        region = data.aws_region.current.name
    }
    orca_recovery_adapter_task_arn = data.terraform_remote_state.cumulus.outputs.orca_recovery_adapter_task.task_arn
    workflow_config = data.terraform_remote_state.cumulus.outputs.workflow_config
    system_bucket = data.terraform_remote_state.daac.outputs.bucket_map.internal.name
}