resource "aws_s3_bucket" "static_bucket" {
  bucket = "jazeelstaticwebsite.sctp-sandbox.com"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "enable_public_access" {
  bucket = aws_s3_bucket.static_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.static_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy.json

  depends_on = [ aws_s3_bucket_public_access_block.enable_public_access ]
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.static_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.sctp_zone.zone_id  #Zone ID of hosted zone: sctp-sandbox.com
  name    = "jazeelstaticwebsite"                    # Bucket name prefix, before your domain
  type    = "A"

  alias {
    name                   = aws_s3_bucket_website_configuration.website.website_domain  #S3 website configuration attribute: website_domain
    zone_id                = aws_s3_bucket.static_bucket.hosted_zone_id                  # Hosted zone of the S3 bucket, Attribute: hosted_zone_id
    evaluate_target_health = true
  }
}