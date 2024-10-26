locals {
  ssh_port   = 22
  http_port  = 80
  https_port = 443
  django_port = 8000
  postgres_port = 5432

  admin_public_ip = data.external.admin_public_ip.result["admin_public_ip"]
}
