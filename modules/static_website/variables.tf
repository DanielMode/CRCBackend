variable "bucket_name" {
  description = "The name of the S3 bucket for the website."
  type        = string
}

variable "domain_name" {
  description = "The custom domain name for the website."
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for CloudFront."
  type        = string
}
