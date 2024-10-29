locals {
  s3_origin_id = join("_", ["website_origin", var.project_name])
  website_domain_name = join(".", ["www", var.domain_name])
}