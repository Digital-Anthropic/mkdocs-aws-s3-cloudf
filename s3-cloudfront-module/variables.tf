variable "bucket_name" {
  type = string
  description = "bucket name"
  default = "mkdocs-bucket"
}

variable "cloudfront_price_class" {
  type = string
  description = "cloudfront price class"
  default = "PriceClass_100"
}

variable "lambda-arn" {
  type = map(object({
    lambda_arn = any
  }))
}