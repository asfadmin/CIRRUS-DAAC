module "orca_recovery_adapter_workflow" {
  source = "https://github.com/nasa/cumulus/releases/download/v17.0.0/terraform-aws-cumulus-workflow.zip"

  prefix          = local.prefix
  name            = "OrcaRecoveryAdapterWorkflow"
  workflow_config = local.workflow_config
  system_bucket   = local.system_bucket
  tags            = local.default_tags

  state_machine_definition = templatefile(
    "${path.module}/orca_recovery_adapter_workflow.asl.json",
    {
      orca_recovery_adapter_task: local.orca_recovery_adapter_task_arn
    }
  )
}

