resource "aws_s3_bucket" "dashboard-bucket" {
  bucket = "${local.prefix}-dashboard"
}
