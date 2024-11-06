variable "domain_name" {
  description = "The primary domain name for the website and certificate."
  type        = string
}

variable "bucket_name" {
  description = "The name of the S3 bucket for the website."
  type        = string
}

variable "route53_zone_id" {
  description = "The Route 53 hosted zone ID for the domain."
  type        = string
}

variable "lambda_filename" {
  description = "Path to the zipped Lambda code file for the visitor tracker function."
  type        = string
}

variable "api_name" {
  description = "The name for the API Gateway that will track website visitors."
  type        = string
  default     = "VisitorTrackerAPI"
}
