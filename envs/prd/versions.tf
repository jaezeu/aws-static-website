terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.31.0"
    }
  }
  cloud {
    organization = "jaz-test-org"

    workspaces {
      name = "cloudfront-s3-prd"
    }
  }
}