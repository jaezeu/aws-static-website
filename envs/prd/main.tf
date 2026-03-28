locals {
  env           = "prd"
  domain_prefix = "jaz-cloudfront"
  zone_name     = "sctp-sandbox.com"
}

module "static_web_stack" {
  source = "../../modules/cloudfront-s3"

  env                 = local.env
  acm_certificate_arn = module.acm.acm_certificate_arn
  aliases             = ["${local.domain_prefix}-${local.env}.${local.zone_name}"]
  web_acl_id          = module.waf.web_acl_arn
  prefix              = local.domain_prefix
}

module "waf" {
  source = "../../modules/waf"

  providers = {
    aws = aws.us-east-1
  }

  env = local.env
}

module "acm" {
  #checkov:skip=CKV_TF_1:Ensure Terraform module sources use a commit hash
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 6.3"

  providers = {
    aws = aws.us-east-1
  }

  domain_name       = "${local.domain_prefix}-${local.env}.${local.zone_name}"
  zone_id           = data.aws_route53_zone.nonprod.zone_id
  validation_method = "DNS"
}

module "zone" {
  #checkov:skip=CKV_TF_1:Ensure Terraform module sources use a commit hash
  source  = "terraform-aws-modules/route53/aws"
  version = "~> 6.4"

  name        = local.zone_name
  create_zone = false

  records = {
    cloudfront_ipv4 = {
      name = "${local.domain_prefix}-${local.env}"
      type = "A"
      alias = {
        name    = "${module.static_web_stack.cloudfront_domain}"
        zone_id = "Z2FDTNDATAQYW2"
      }
    }
  }
}