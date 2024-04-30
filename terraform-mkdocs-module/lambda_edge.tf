data "archive_file" "index_redirect_zip" {
  type        = "zip"
  output_path = "terraform-mkdocs-module/index_redirect.js.zip"
  source_file = "terraform-mkdocs-module/index_redirect.js"
}

resource "aws_iam_role_policy" "lambda_execution" {
  name_prefix = "lambda-execution-policy-"
  role        = aws_iam_role.lambda_execution.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:CreateLogGroup"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "lambda_execution" {
  name_prefix        = "lambda-execution-role-"
  description        = "Managed by Terraform"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "edgelambda.amazonaws.com",
          "lambda.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

provider "aws" {
  region = "us-east-1"
  alias = "aws_us"
}

resource "aws_lambda_function" "index_redirect" {
  description      = "Managed by Terraform"
  filename         = "terraform-mkdocs-module/index_redirect.js.zip"
  function_name    = "folder-index-redirect"
  handler          = "index_redirect.handler"
  source_code_hash = data.archive_file.index_redirect_zip.output_base64sha256
  provider         = aws.aws_us
  publish          = true
  role             = aws_iam_role.lambda_execution.arn
  runtime          = "nodejs20.x"

}