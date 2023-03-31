provider "aws" {
  region = "us-west-1"
}

resource "aws_s3_bucket" "sbg_cgc_bucket" {
  bucket = "sbg-cgc-dev-tmpfiles" 
  acl    = "private"
}

resource "aws_cloudfront_origin_access_identity" "sbg_cgc_identity" {
  comment = "S3 Origin Identity for SBG-CGC"
}

resource "aws_cloudfront_distribution" "sbg_cgc_distribution" {
  origin {
    domain_name = aws_s3_bucket.sbg_cgc_bucket.bucket_regional_domain_name
    origin_id   = "sbg_cgc_s3_origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.sbg_cgc_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront Distribution for SBG-CGC"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "sbg_cgc_s3_origin"

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

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

output "s3_bucket_name" {
  value = aws_s3_bucket.sbg_cgc_bucket.bucket
}

output "cloudfront_domain" {
  value = aws_cloudfront_distribution.sbg_cgc_distribution.domain_name
}
