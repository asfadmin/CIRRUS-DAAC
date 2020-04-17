output "cma_layer_arn" {
  value = "${aws_lambda_layer_version.cma_layer.arn}"
}

output "bucket_map" {
  value = local.bucket_map
}
