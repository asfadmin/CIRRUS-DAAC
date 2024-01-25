## Bucket policy required for Orca load balancer 
## See https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/enable-access-logs.html

resource "aws_s3_bucket_policy" "load_balancer_log_access" {
    bucket = local.system_bucket
    policy = data.template_file.load_balancer_s3_policy.rendered
}

data "template_file" "load_balancer_s3_policy" {
  template = file("${path.module}/orca_cumulus_internal_s3_policy.tpl")

  vars = {
    prefix = local.prefix
    elb_account_id = var.elb_account_id 
  }
}
