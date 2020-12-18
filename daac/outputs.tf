output "cma_layer_arn" {
  value = aws_lambda_layer_version.cma_layer.arn
}

output "bucket_map" {
  value = local.bucket_map
}

output "bucket_map_key" {
  value = ""
}

/* export bucket_map_key if defined so it can be used in the cumulus step

/*
output "bucket_map_key" {
  value = "${aws_s3_bucket_object.tea_bucket_map.key}"
}
*/