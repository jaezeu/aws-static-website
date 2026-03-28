# AWS Static Website (CloudFront + S3 + WAF + Route53)

Terraform project to provision a static website stack on AWS with:

- Amazon S3 as the website content origin
- Amazon CloudFront distribution with Origin Access Control (OAC)
- AWS WAFv2 Web ACL attached to CloudFront
- ACM certificate (in us-east-1) for custom domain
- Route53 DNS alias record for the CloudFront endpoint

## Architecture Diagram

![cloudfront-s3-tfcloud drawio (1)](https://github.com/jaezeu/cloudfront-static-web-module/assets/48310743/c934f75a-a1fc-4bc2-b04d-d08d20467216)

## Repository Layout

```text
envs/
	nonprd/   # non-production Terraform root module
	prd/      # production Terraform root module
modules/
	cloudfront-s3/  # S3 bucket, CloudFront distribution, OAC, bucket policy
	waf/            # WAFv2 Web ACL for CloudFront
static-website/   # website files to upload to S3
```

## Environments

This repo has two deployable environments:

- nonprd
- prd

Both environments use the same module pattern with environment-specific Terraform Cloud workspaces.

## Prerequisites

1. Terraform CLI >= 1.14
2. AWS credentials with permissions for S3, CloudFront, WAFv2, ACM, Route53, and IAM policy changes
3. Existing Route53 hosted zone: `sctp-sandbox.com`
4. Terraform Cloud organization and workspaces configured:
	 - `cloudfront-s3-nonprd`
	 - `cloudfront-s3-prd`

Notes:

- CloudFront requires ACM certificates in us-east-1. This is already handled by the provider alias in the environment configs.
- The `s3_only_hosting` folder is intentionally not part of the active deployment flow.

## Terraform Cloud Setup

Each environment root module contains a `terraform` `cloud` block.

If you have not authenticated your CLI yet:

```bash
terraform login
```

## Deploy Infrastructure

Run these commands from the selected environment directory.

### Deploy nonprd

```bash
cd envs/nonprd
terraform init
terraform plan
terraform apply
```

### Deploy prd

```bash
cd envs/prd
terraform init
terraform plan
terraform apply
```

## Useful Terraform Outputs

After apply, each environment returns:

- `cf_domain` - CloudFront distribution domain name
- `cf_id` - CloudFront distribution ID
- `bucket_name` - S3 bucket name used as origin

Get outputs with:

```bash
terraform output
```

## Upload Website Content

After infrastructure is created, upload the local site files to the provisioned S3 bucket.

1. Get bucket name from Terraform output.
2. Sync local static files.

Example:

```bash
aws s3 sync static-website/ s3://<bucket_name>/ --delete
```

## Invalidate CloudFront Cache

After uploading new content, invalidate cache so updates are served immediately.

```bash
aws cloudfront create-invalidation \
	--distribution-id <cf_id> \
	--paths "/*"
```

## Domain and DNS

The environment configuration creates an alias record in Route53 pointing to CloudFront.

Current naming pattern:

- nonprd: `jaz-cloudfront-nonprd.sctp-sandbox.com`
- prd: `jaz-cloudfront-prd.sctp-sandbox.com`

## Security Notes

- S3 access is restricted to CloudFront through bucket policy conditions on distribution ARN.
- CloudFront uses OAC for signed origin requests.
- WAF managed rule group `AWSManagedRulesCommonRuleSet` is enabled.

## Troubleshooting

### ACM validation pending

- Confirm hosted zone exists and is authoritative.
- Check DNS validation records created by ACM in Route53.

### Access denied from CloudFront

- Verify bucket policy is attached and references the correct CloudFront distribution ARN.
- Confirm CloudFront origin points to the S3 regional domain name.

### Site changes not visible

- Re-run `aws s3 sync`.
- Create a CloudFront invalidation for updated paths.
