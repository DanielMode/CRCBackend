 variable "domain_name" {
  description = "The domain name to be used for the certificate."
  type        = string
}

variable "zone_id" {
  description = "The Route 53 hosted zone ID for DNS validation."
  type        = string
}
