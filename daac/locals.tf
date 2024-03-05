locals {
  prefix = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}"

  default_tags = {
    Deployment = local.prefix
  }

  dar_yes_tags = {
    DAR        = "YES"
  }

  dar_no_tags = {
    DAR        = "NO"
  }


  standard_bucket_names  = [for n in var.standard_bucket_names : "${local.prefix}-${n}"]
  protected_bucket_names = [for n in var.protected_bucket_names : "${local.prefix}-${n}"]
  public_bucket_names    = [for n in var.public_bucket_names : "${local.prefix}-${n}"]
  workflow_bucket_names  = [for n in var.workflow_bucket_names : "${local.prefix}-${n}"]
  partner_bucket_names   = [for n in var.partner_bucket_names : n]

  standard_bucket_map  = { for n in var.standard_bucket_names : n => { name = "${local.prefix}-${n}", type = n } }
  protected_bucket_map = { for n in var.protected_bucket_names : n => { name = "${local.prefix}-${n}", type = "protected" } }
  public_bucket_map    = { for n in var.public_bucket_names : n => { name = "${local.prefix}-${n}", type = "public" } }
  workflow_bucket_map  = { for n in var.workflow_bucket_names : n => { name = "${local.prefix}-${n}", type = "workflow" } }
  partner_bucket_map   = { for n in var.partner_bucket_names : n => { name = n, type = "partner" } }
  internal_bucket_map = {
    internal = {
      name = "${local.prefix}-internal"
      type = "internal"
    }
  }

  # creates a TEA style bucket map, is outputted via outputs.tf
  bucket_map = merge(local.standard_bucket_map, local.internal_bucket_map,
    local.protected_bucket_map, local.public_bucket_map,
  local.workflow_bucket_map, local.partner_bucket_map)
}
