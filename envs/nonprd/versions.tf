terraform {
  required_version = ">= 1.14"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.31"
    }
  }
  cloud {
    organization = "jaz-test-org"

    workspaces {
      name = "cloudfront-s3-nonprd"
    }
  }
}