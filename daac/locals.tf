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
  # Any new keys options that have maturity specific overrides need to be added here.
  bucket_config = {
    for k in setunion(keys(var.bucket_config_base), keys(var.bucket_config)) : k => {
      # If a new bucket is defined in the maturity specific overrides without
      # a `type` attribute, then `coalesce` will throw a null error.
      type = coalesce(
        # Check the base first here so it can't be overridden.
        try(var.bucket_config_base[k].type, null),
        try(var.bucket_config[k].type, null),
      )
      oai = try(
        coalesce(
          try(var.bucket_config[k].oai, null),
          try(var.bucket_config_base[k].oai, null),
        ),
        null,
      )
    }
  }

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
