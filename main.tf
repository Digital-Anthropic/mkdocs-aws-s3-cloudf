module "terraform_s3_cloudfront_lambda" {
  source                = "./terraform-mkdocs-module"
  bucket_name           = var.bucket_name
  cloudfront_price_class = var.cloudfront_price_class
}

output "bucket_endpoint" {
  value = module.terraform_s3_cloudfront_lambda.bucket_endpoint
}

output "cloudfront_domain_name" {
  value = module.terraform_s3_cloudfront_lambda.cloudfront_domain_name
}
