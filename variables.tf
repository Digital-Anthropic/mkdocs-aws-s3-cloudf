variable "bucket_name" {
  type = string
  description = "bucket name"
  default = "terraform-modules-docs"
}

variable "cloudfront_price_class" {
  type = string
  description = "cloudfront price class"
  default = "PriceClass_100"
}
