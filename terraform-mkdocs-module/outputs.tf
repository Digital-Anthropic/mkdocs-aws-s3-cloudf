output "bucket_endpoint" {
  value       = aws_s3_bucket.mkdocs_bucket.bucket_regional_domain_name
  description = "The regional domain name of the S3 bucket"
}

output "cloudfront_domain_name" {
  value       = aws_cloudfront_distribution.mkdocs_distribution.domain_name
  description = "The domain name of the CloudFront distribution"
}