# S3 Bucket for Grafana data
resource "aws_s3_bucket" "grafana_data" {
  bucket = "${var.project_name}-grafana-data-${random_string.bucket_suffix.result}"

  tags = var.common_tags
}

resource "aws_s3_bucket_versioning" "grafana_data" {
  bucket = aws_s3_bucket.grafana_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "grafana_data" {
  bucket = aws_s3_bucket.grafana_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "grafana_data" {
  bucket = aws_s3_bucket.grafana_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Random string for bucket naming
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}



