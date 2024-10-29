locals {
  s3_origin_id = join("_", ["website_origin", var.project_name])
  website_domain_name = join(".", ["www", data.aws_route53_zone.this.name])
}