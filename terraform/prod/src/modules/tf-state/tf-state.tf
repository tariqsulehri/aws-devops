
# S3 bucket for terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy # DON'T set true for production state buckets; change only if you understand implications
}

# Block public access
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning
resource "aws_s3_bucket_versioning" "terraform_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption with AWS Managed key (SSE-S3)
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_crypto_conf" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# # Optional: lifecycle rule to expire non-current versions or incomplete multipart uploads (helps cost control)
# resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
#   bucket = aws_s3_bucket.terraform_state.id

#   rule {
#     id     = "expire-noncurrent-versions"
#     status = "Enabled"

#     noncurrent_version_expiration {
#       days = 90
#     }

#     abort_incomplete_multipart_upload {
#       days_after_initiation = 7
#     }
#   }
# }

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
