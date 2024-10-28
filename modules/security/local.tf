locals {
  ssh_port   = 22
  http_port  = 80
  https_port = 443
  backend_rds_app_port = 8000
  backend_redis_app_port = 9000
  postgres_port = 5432
  redis_port = 6379

  admin_public_ip = data.external.admin_public_ip.result["admin_public_ip"]
}
