## disabled rules
rule "terraform_documented_outputs" {
  enabled = false
}
rule "terraform_documented_variables" {
  enabled = false
}
rule "terraform_naming_convention" {
  # forces snake case for many things, including deployed lambda names, don't
  # want that
  enabled = false
}
rule "terraform_unused_declarations" {
  # this needs to be disabled so that DAACs using CIRRUS have the option to use
  # any given variable defined here
  enabled = false
}


## default ruleset
rule "terraform_deprecated_interpolation" {
  enabled = true
}
rule "terraform_deprecated_index" {
  enabled = true
}
rule "terraform_comment_syntax" {
  enabled = true
}
rule "terraform_typed_variables" {
  enabled = true
}
rule "terraform_module_pinned_source" {
  enabled = true
}
rule "terraform_required_version" {
  enabled = true
}
rule "terraform_required_providers" {
  enabled = true
}
rule "terraform_standard_module_structure" {
  enabled = true
}
rule "terraform_workspace_remote" {
  enabled = true
}


## AWS non-deep rules
rule "aws_db_instance_invalid_type" {
  enabled = true
}
rule "aws_elasticache_cluster_invalid_type" {
  enabled = true
}
rule "aws_route_not_specified_target" {
  enabled = true
}
rule "aws_route_specified_multiple_targets" {
  enabled = true
}
rule "aws_instance_previous_type" {
  enabled = true
}
rule "aws_db_instance_previous_type" {
  enabled = true
}
rule "aws_db_instance_default_parameter_group" {
  enabled = true
}
rule "aws_elasticache_cluster_previous_type" {
  enabled = true
}
rule "aws_elasticache_cluster_default_parameter_group" {
  enabled = true
}
