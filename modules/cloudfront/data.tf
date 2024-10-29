data "aws_cloudfront_cache_policy" "managed_caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_origin_request_policy" "managed_managed_cors_s3_origin" {
  name = "Managed-CORS-S3Origin"
}

data "aws_route53_zone" "this" {
  name         = var.domain_name
  private_zone = false
}
