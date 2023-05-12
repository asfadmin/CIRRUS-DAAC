terraform {
  required_providers {
    aws  = "~> 2.46.0"
    null = "~> 2.1.0"
  }
  backend "s3" {}
}

provider "aws" {
  ignore_tags {
    key_prefixes = ["gsfc-ngap"]
  }
}
