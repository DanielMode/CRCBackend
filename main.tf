terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  # profile = "sso-profile"
}

terraform {
  backend "s3" {
    bucket         = "terra-backende"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    # profile        = "sso-profile"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

# Module: ACM Certificate
module "acm_certificate" {
  source      = "./modules/acm_certificate"
  domain_name = var.domain_name
  zone_id     = var.route53_zone_id
}

# Module: Static Website (S3 + CloudFront)
module "static_website" {
  source              = "./modules/static_website"
  bucket_name         = var.bucket_name
  domain_name         = var.domain_name
  acm_certificate_arn = module.acm_certificate.cert_arn
}

# Module: Route 53 Configuration
module "route53" {
  source      = "./modules/route53"
  domain_name = var.domain_name
  cf_alias    = module.static_website.cloudfront_distribution_alias
  cf_zone_id  = "Z2FDTNDATAQYW2" # AWS Global CloudFront Zone ID, commonly used
}

# Module: Visitor Tracker (API Gateway + Lambda + DynamoDB)
module "visitor_tracker" {
  source          = "./modules/visitor_tracker"
  lambda_filename = var.lambda_filename
  api_name        = var.api_name
}

# Outputs for convenience
output "website_url" {
  description = "The CloudFront distribution URL for the static website."
  value       = module.static_website.cloudfront_distribution_alias
}

