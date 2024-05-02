module "terraform-s3-cloudfront-lambda" {
  source                = "./terraform-mkdocs-module"
  bucket_name           = var.bucket_name
  cloudfront_price_class = var.cloudfront_price_class
}

output "bucket_endpoint" {
  value = module.mkdocs.bucket_endpoint
}

output "cloudfront_domain_name" {
  value = module.mkdocs.cloudfront_domain_name
}
