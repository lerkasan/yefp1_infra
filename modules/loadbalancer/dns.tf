resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = data.aws_route53_zone.this.name
  type    = "A"

  alias {
    name                   = aws_lb.app.dns_name
    zone_id                = aws_lb.app.zone_id
    evaluate_target_health = true
  }
}

# resource "aws_route53_zone" "api" {
#   name = join(".", ["api", data.aws_route53_zone.this.name])

#   tags = {
#     Name        = join("_", [var.project_name, "_api_route53_zone"])
#     terraform   = "true"
#     environment = var.environment
#     project     = var.project_name
#   }
# }

resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.this.zone_id
  #   zone_id = aws_route53_zone.api.zone_id
  name = local.api_domain_name
  type = "A"

  alias {
    name                   = aws_lb.app.dns_name
    zone_id                = aws_lb.app.zone_id
    evaluate_target_health = false
  }
}

# resource "aws_route53_zone" "cache" {
#   name = join(".", ["cache", data.aws_route53_zone.this.name])

#   tags = {
#     Name        = join("_", [var.project_name, "_cache_route53_zone"])
#     terraform   = "true"
#     environment = var.environment
#     project     = var.project_name
#   }
# }

resource "aws_route53_record" "cache" {
  zone_id = data.aws_route53_zone.this.zone_id
  #   zone_id = aws_route53_zone.cache.zone_id
  name = local.cache_domain_name
  type = "A"

  alias {
    name                   = aws_lb.app.dns_name
    zone_id                = aws_lb.app.zone_id
    evaluate_target_health = false
  }
}



resource "aws_acm_certificate" "api" {
  domain_name       = local.api_domain_name
  validation_method = "DNS"
}

resource "aws_route53_record" "validation_api" {
  for_each = {
    for dvo in aws_acm_certificate.api.domain_validation_options : dvo.domain_name => {
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

resource "aws_acm_certificate_validation" "api" {
  certificate_arn         = aws_acm_certificate.api.arn
  validation_record_fqdns = [for record in aws_route53_record.validation_api : record.fqdn]
}


resource "aws_acm_certificate" "cache" {
  domain_name       = local.cache_domain_name
  validation_method = "DNS"
}

resource "aws_route53_record" "validation_cache" {
  for_each = {
    for dvo in aws_acm_certificate.cache.domain_validation_options : dvo.domain_name => {
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

resource "aws_acm_certificate_validation" "cache" {
  certificate_arn         = aws_acm_certificate.cache.arn
  validation_record_fqdns = [for record in aws_route53_record.validation_cache : record.fqdn]
}
