##############################################
# S3 + CloudFront Module
# Purpose: Host and deliver React/Vite frontend build files
# Author: DevOps Team
# FIX: Added s3:ListBucket permission to the bucket policy,
#      which is mandatory for CloudFront to resolve the default_root_object.
##############################################

locals {
  name_prefix = "${var.project_name}-${var.env}"
}

# -----------------------------
# 1️⃣ S3 Bucket for Frontend Hosting
# -----------------------------
resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "${local.name_prefix}-frontend-bucket"

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-frontend-bucket"
  })
}

# ✅ Ownership Controls (Mandatory for BucketOwnerEnforced)
resource "aws_s3_bucket_ownership_controls" "frontend_bucket_ownership" {
  bucket = aws_s3_bucket.frontend_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# ✅ Block all public access (Crucial for OAC security)
resource "aws_s3_bucket_public_access_block" "frontend_bucket_access" {
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ✅ Versioning (Recommended for rollback safety)
resource "aws_s3_bucket_versioning" "frontend_bucket_versioning" {
  bucket = aws_s3_bucket.frontend_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ✅ Optional: Static website configuration (for SPA routing support)
# NOTE: This configuration is only used by the bucket's *website endpoint*,
#       but it is useful here to define the index and error documents clearly.
#       CloudFront relies on 'default_root_object' and 'custom_error_response'.
resource "aws_s3_bucket_website_configuration" "frontend_website_config" {
  bucket = aws_s3_bucket.frontend_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# -----------------------------
# 2️⃣ Origin Access Control (CloudFront → S3)
# -----------------------------
resource "aws_cloudfront_origin_access_control" "frontend_oac" {
  name                              = "${local.name_prefix}-frontend-oac"
  description                       = "OAC for CloudFront to access S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# -----------------------------
# 3️⃣ CloudFront Distribution
# -----------------------------
resource "aws_cloudfront_distribution" "frontend_cdn" {
  enabled             = true
  comment             = "CloudFront distribution for ${local.name_prefix} frontend"
  default_root_object = "index.html"

  origin {
    # CRITICAL: Use bucket_regional_domain_name with OAC
    domain_name              = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
    origin_id                = "S3-${aws_s3_bucket.frontend_bucket.bucket}"
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend_oac.id
    # IMPORTANT: Do not use s3_origin_config when using OAC
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.frontend_bucket.bucket}"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  # SPA Routing: Send 403/404 errors back to index.html
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
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

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-frontend-cdn"
  })
}

# -----------------------------
# 4️⃣ S3 Bucket Policy (Allow CloudFront OAC to Access S3) - FIX APPLIED
# -----------------------------
data "aws_iam_policy_document" "frontend_s3_policy" {
  # Statement 1: Allow CloudFront to retrieve objects (s3:GetObject)
  statement {
    sid       = "AllowCloudFrontOacGetObject"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.frontend_bucket.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.frontend_cdn.arn]
    }
  }

  # 🌟 FIX: Statement 2: Allow CloudFront to list bucket contents (s3:ListBucket)
  # This is crucial for CloudFront to resolve the root object (index.html).
  statement {
    sid       = "AllowCloudFrontOacListBucket"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.frontend_bucket.arn] # Note: No /*

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.frontend_cdn.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "frontend_bucket_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id
  policy = data.aws_iam_policy_document.frontend_s3_policy.json
}

# -----------------------------
# 5️⃣ Outputs
# -----------------------------
output "frontend_s3_bucket_name" {
  value = aws_s3_bucket.frontend_bucket.bucket
}

output "frontend_cloudfront_domain_name" {
  value = aws_cloudfront_distribution.frontend_cdn.domain_name
}

output "frontend_website_url" {
  value = "https://${aws_cloudfront_distribution.frontend_cdn.domain_name}"
}