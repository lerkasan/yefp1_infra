locals {
  http_port = 80
  https_port = 443
  backend_rds_app_port = 8000
  backend_redis_app_port = 9000
  website_domain_name = join(".", ["www", data.aws_route53_zone.this.name])
  api_domain_name = join(".", ["api", data.aws_route53_zone.this.name])
  cache_domain_name = join(".", ["cache", data.aws_route53_zone.this.name])
}
