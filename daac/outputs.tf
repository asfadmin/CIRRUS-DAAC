output "bucket_map" {
  value = local.bucket_map
}

output "bucket_map_key" {
  value = ""
}

output "cirrus_core_version" {
  value = var.CIRRUS_CORE_VERSION
}

output "cirrus_daac_version" {
  value = var.CIRRUS_DAAC_VERSION
}

output "cma_layer_arn" {
  value = aws_lambda_layer_version.cma_layer.arn
}

/* export bucket_map_key if defined so it can be used in the cumulus step

/*
output "bucket_map_key" {
  value = "${aws_s3_object.tea_bucket_map.key}"
}
*/
