resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = {
    Name        = join("_", [var.project_name, "website_s3_bucket"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = var.s3_object_ownership
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "allow_cloudfront_access_only" {
  count = var.is_website ? 1 : 0

  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.allow_cloudfront_access_only.json
}

resource "aws_s3_bucket_website_configuration" "this" {
  count = var.is_website ? 1 : 0

  bucket = aws_s3_bucket.this.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "allow_loadbalancer_to_write_logs" {
  count = var.is_alb_log_bucket ? 1 : 0

  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.allow_elb_logging.json
}