resource "aws_s3_bucket" "mkdocs_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_website_configuration" "mkdocs_website" {
  bucket = aws_s3_bucket.mkdocs_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "mkdocs_ownership_controls" {
  bucket = aws_s3_bucket.mkdocs_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "mkdocs_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.mkdocs_ownership_controls]

  bucket = aws_s3_bucket.mkdocs_bucket.id
  acl    = "public-read"
}

resource "aws_cloudfront_distribution" "mkdocs_distribution" {
  origin {
    domain_name = aws_s3_bucket.mkdocs_bucket.bucket_regional_domain_name
    origin_id   = "S3Origin"

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  price_class         = var.cloudfront_price_class
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "S3Origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}