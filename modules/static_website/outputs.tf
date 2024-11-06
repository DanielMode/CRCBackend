output "cloudfront_distribution_alias" {
  description = "The CloudFront distribution alias for Route 53 configuration."
  value       = aws_cloudfront_distribution.website_distribution.domain_name
}
