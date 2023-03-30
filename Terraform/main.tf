# main.tf

provider "aws" {
  region = "us-west-1"
}

locals {
  bucket_name = "dev-icdc-tmpfiles"
  lambda_function_name = "s3_tmp_cleanup"
}

resource "aws_s3_bucket" "dev_tier_bucket" {
  bucket = local.bucket_name
  acl    = "private"
}

resource "aws_cloudfront_distribution" "lower_tier_distribution" {
  origin {
    domain_name = "nci.nih.gov"
    origin_id   = local.bucket_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.dev_tier_oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.bucket_name

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

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

resource "aws_cloudfront_origin_access_identity" "dev_tier_oai" {
  comment = "Origin access identity for lower-tier distribution"
}

resource "aws_s3_bucket_policy" "dev_tier_bucket_policy" {
  bucket = aws_s3_bucket.dev_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "s3:GetObject"
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.dev_tier_bucket.arn}/*"
        Principal = {
          AWS = "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.lower_tier_oai.id}"
        }
      }
    ]
  })
}

resource "aws_lambda_function" "s3_tmp_cleanup" {
  function_name = local.lambda_function_name
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_exec.arn

  filename = "s3_tmp_cleanup.zip"

  environment {
    variables = {
      BUCKET_NAME = local.bucket_name
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "s3_tmp_cleanup_lambda_exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_exec" {
  policy_arn = "arn:aws:iam