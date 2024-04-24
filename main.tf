module "mkdocs" {
  source                = "./terraform-mkdocs-module"
  bucket_name           = "your-bucket-name"
  cloudfront_price_class = "PriceClass_100"
}

output "bucket_endpoint" {
  value = module.mkdocs.bucket_endpoint
}

output "cloudfront_domain_name" {
  value = module.mkdocs.cloudfront_domain_name
}