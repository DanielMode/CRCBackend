variable "domain_name" {
  description = "The domain name for the Route 53 record."
  type        = string
}

variable "cf_alias" {
  description = "CloudFront distribution alias."
  type        = string
}

variable "cf_zone_id" {
  description = "CloudFront distribution's hosted zone ID."
  type        = string
}
