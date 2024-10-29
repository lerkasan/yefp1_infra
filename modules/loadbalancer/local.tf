locals {
  http_port = 80
  https_port = 443
  backend_rds_app_port = 8000
  backend_redis_app_port = 9000
  website_domain_name = join(".", ["www", var.domain_name])
}
