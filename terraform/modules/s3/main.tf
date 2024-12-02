resource "aws_s3_bucket" "ml_storage" {
  bucket = var.bucket_name

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

resource "aws_s3_bucket_versioning" "ml_storage" {
  bucket = aws_s3_bucket.ml_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ml_storage" {
  bucket = aws_s3_bucket.ml_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "ml_storage" {
  bucket = aws_s3_bucket.ml_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}