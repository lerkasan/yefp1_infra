data "aws_route53_zone" "this" {
  name         = var.domain_name
  private_zone = false
}

data "aws_acm_certificate" "this" {
  domain      = var.domain_name
  statuses    = ["ISSUED"]
  types       = ["AMAZON_ISSUED"]
  key_types   = ["EC_prime256v1"]
  most_recent = true
}