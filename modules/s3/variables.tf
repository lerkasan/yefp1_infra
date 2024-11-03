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
  description = "S3 bucket name"
  type    = string
}

variable "is_website" {
  description = "Should S3 bucket be configured as a website"
  type    = bool
  default = false
}


variable "is_alb_log_bucket" {
  description = "Should S3 bucket be configured as a storage for load balancer access logs"
  type    = bool
  default = false
}

variable "s3_object_ownership" {
  description = "S3 object ownership (this parameter also enables/disables ACL)"
  type = string
  default = "BucketOwnerEnforced"
  
  validation {
    condition     = contains(["BucketOwnerPreferred", "BucketOwnerEnforced"], var.s3_object_ownership)
    error_message = "Valid values for a variable s3_object_ownership are BucketOwnerEnforced, BucketOwnerPreferred"
  }
}

# ----------------- CloudFront parameters --------------

variable "cloudfront_distribution_arn" {
  description   = "CloudFront distribution ARN"
  type          = string
  default = ""
}