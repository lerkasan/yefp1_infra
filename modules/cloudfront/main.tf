resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  price_class = var.price_class
  default_root_object = "index.html"
  aliases = [local.website_domain_name]
  web_acl_id = var.waf_enabled ? aws_wafv2_web_acl.this[0].arn : null

  origin {
    domain_name              = var.s3_origin_bucket_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
    origin_id                = local.s3_origin_id
    origin_shield {
      enabled = var.origin_shield_enabled
      origin_shield_region = var.aws_region
	}
  }

  default_cache_behavior {
    allowed_methods  = var.allowed_methods
    cached_methods   = var.cached_methods
    target_origin_id = local.s3_origin_id

    cache_policy_id = data.aws_cloudfront_cache_policy.managed_caching_optimized.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.managed_managed_cors_s3_origin.id

    viewer_protocol_policy = "redirect-to-https"  # "allow-all"
    min_ttl                = 0
    default_ttl            = var.default_ttl
    max_ttl                = var.max_ttl
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  logging_config {
    include_cookies = false
    bucket          = var.website_access_logs_bucket_name
    prefix          = var.project_name
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.www.arn
    ssl_support_method = "sni-only"
  }

  tags = {
    Name        = join("_", [var.project_name, "_cloudfront_distribution"])
    terraform   = "true"
    project     = var.project_name
  }
}

resource "aws_cloudfront_origin_access_control" "this" {
  name                              = join("_", [var.project_name, "cloudfront_origin_access_control"])
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_wafv2_web_acl" "this" {
  count  = var.waf_enabled ? 1 : 0

  name  = "cloudfront-webacl"
  scope = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 0

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "cloudfrontVisibilityConfig"
    sampled_requests_enabled   = true
  }

  tags = {
    Name        = join("_", [var.project_name, "_waf_for_cloudfront"])
    terraform   = "true"
    project     = var.project_name
  }
}