locals {
  prefix = "${var.DEPLOY_NAME}-cumulus-${var.MATURITY}"

  default_tags = {
    Deployment = local.prefix
  }

  dar_yes_tags = {
    DAR = "YES"
  }

  dar_no_tags = {
    DAR = "NO"
  }

  # Merge the bucket_config with base
  # First, merge any configs that would override the base
  partial_bucket_config = {
    for n, cfg in var.bucket_config_base : n => merge(cfg, lookup(var.bucket_config, n, cfg))
  }
  # Then combine the override map with the merged base to capture additions
  bucket_config = merge(var.bucket_config, local.partial_bucket_config)

  # Bucket types. These lists should not overlap
  standard_bucket_names  = toset([for n, cfg in local.bucket_config : "${local.prefix}-${n}" if cfg.type == "standard"])
  protected_bucket_names = toset([for n, cfg in local.bucket_config : "${local.prefix}-${n}" if cfg.type == "protected"])
  public_bucket_names    = toset([for n, cfg in local.bucket_config : "${local.prefix}-${n}" if cfg.type == "public"])
  workflow_bucket_names  = toset([for n, cfg in local.bucket_config : "${local.prefix}-${n}" if cfg.type == "workflow"])

  # Bucket attributes. These will enable additional configuration on some bucket
  # in one of the lists above.
  distribution_bucket_oais = { for n, cfg in local.bucket_config : n => cfg.oai if cfg.oai != null }

  base_bucket_map = {
    for n, cfg in local.bucket_config : n => {
      name = "${local.prefix}-${n}"
      type = cfg.type == "standard" ? n : cfg.type
    }
  }
  partner_bucket_map = {
    for n in var.partner_bucket_names : n => {
      name = n
      type = "partner"
    }
  }
  internal_bucket_map = {
    internal = {
      name = "${local.prefix}-internal"
      type = "internal"
    }
  }

  # creates a TEA style bucket map, is outputted via outputs.tf
  bucket_map = merge(
    local.base_bucket_map,
    local.internal_bucket_map,
    local.partner_bucket_map,
  )
}
