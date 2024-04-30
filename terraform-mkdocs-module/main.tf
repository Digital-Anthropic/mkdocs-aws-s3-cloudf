resource "aws_s3_bucket" "mkdocs_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_policy" "allow_access_from_cloudfront" {
  bucket = aws_s3_bucket.mkdocs_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          AWS = "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.access_identity.id}"
        },
        Action    = [
          "s3:GetObject",
          "s3:ListBucket",
        ],
        Resource  = [
          aws_s3_bucket.mkdocs_bucket.arn,
          "${aws_s3_bucket.mkdocs_bucket.arn}/*",
        ]
      }
    ]
  })
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

resource "aws_cloudfront_origin_access_identity" "access_identity" {
  comment = "OAI"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_lambda_function" "append_index_html" {
  s3_bucket     = "arn:aws:s3:::mkdocs-bucket" 
  filename         = "lambda.zip"
  function_name    = "AppendIndexHtmlLambda"
  role             = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"
  runtime       = "nodejs14.x"
}

resource "aws_lambda_permission" "cloudfront_invoke_permission" {
  statement_id  = "AllowExecutionFromCloudFront"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.append_index_html.arn
  principal     = "edgelambda.amazonaws.com"
}

resource "aws_cloudfront_function" "append_index_html_function" {
  name    = "append_index_html"
  runtime = "cloudfront-js-2.0"

  code = <<-EOT
    function handler(event) {
      const request = event.request;
      const uri = request.uri;

      // Append "index.html" to the request path
      request.uri = uri.endsWith("/") ? uri + "index.html" : uri;

      return request;
    }
  EOT
}

resource "aws_cloudfront_distribution" "mkdocs_distribution" {
  origin {
    domain_name = aws_s3_bucket.mkdocs_bucket.bucket_regional_domain_name
    origin_id   = "S3Origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.access_identity.cloudfront_access_identity_path
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

  lambda_function_association {
    event_type   = "origin-request"
    lambda_arn   = aws_cloudfront_function.append_index_html_function.arn
    include_body = false
  }
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