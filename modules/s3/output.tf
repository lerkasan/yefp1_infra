output "s3_origin_bucket_domain_name" {
  description   = "Regional domain name of S3 bucket"
  value = aws_s3_bucket.this.bucket_regional_domain_name
}

output "s3_bucket_domain_name" {
  description   = "S3 bucket domain name"
  value = aws_s3_bucket.this.bucket_domain_name
}