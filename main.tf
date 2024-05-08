module "terraform_s3_cloudfront_lambda_func" {
  for_each              = local.s3cf
  source                = "./terraform-mkdocs-module"
  bucket_name           = each.value.bucket_name 
  cloudfront_price_class = var.cloudfront_price_class
}

output "bucket_endpoint" {
  value = module.terraform_s3_cloudfront_lambda_func.bucket_endpoint
}

output "cloudfront_domain_name" {
  value = module.terraform_s3_cloudfront_lambda_func.cloudfront_domain_name
}

moved {
  from = module.mkdocs
  to = module.terraform_s3_cloudfront_lambda_func
}
