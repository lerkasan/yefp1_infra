# ---------------- General parameters ----------------

variable "project_name" {
  description   = "Project name"
  type          = string
}

variable "environment" {
  description   = "Environment: dev/stage/prod"
  type          = string
  default       = "stage"
}

# ----------------- S3 parameters -------------------

variable "bucket_name" {
  type    = string
}

variable "is_website" {
  type    = bool
  default = false
}

# ----------------- CloudFront parameters --------------

variable "cloudfront_distribution_arn" {
  description   = "CloudFront distribution ARN"
  type          = string
  default = ""
}