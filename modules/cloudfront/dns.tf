resource "aws_route53_zone" "www" {
  name = join(".", ["www", data.aws_route53_zone.this.name])

  tags = {
    Name        = join("_", [var.project_name, "_www_route53_zone"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.www.zone_id
  name    = aws_route53_zone.www.name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate" "www" {
  domain_name       = aws_route53_zone.www.name
  validation_method = "DNS"
}

resource "aws_route53_record" "validation_www" {
  for_each = {
    for dvo in aws_acm_certificate.www.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.this.zone_id
}

resource "aws_acm_certificate_validation" "www" {
  certificate_arn         = aws_acm_certificate.www.arn
  validation_record_fqdns = [for record in aws_route53_record.validation_www : record.fqdn]
}
