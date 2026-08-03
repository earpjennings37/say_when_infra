resource "aws_s3_bucket" "thanos" {
  bucket = var.bucket_name

  tags = {
    Project   = "thanos"
    ManagedBy = "terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "thanos" {
  bucket = aws_s3_bucket.thanos.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}