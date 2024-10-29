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

variable "domain_name" {
  description   = "Domain name"
  type          = string
}

variable "price_class" {
  description   = "Cloudfront price class"
  type          = string

  validation {
    condition     = contains(["PriceClass_100", "PriceClass_200", "PriceClass_ALL"], var.price_class)
    error_message = "Valid values for a variable price_class are: PriceClass_100 | PriceClass_200 | PriceClass_ALL"
  }
}

variable "website_access_logs_bucket_name" {
  description   = "Bucket name for website access logs "
  type          = string
}

variable "s3_origin_bucket_domain_name" {
  description   = "Regional domain name of a website S3 bucket"
  type          = string
}

variable "allowed_methods" {
  description = "Allowed methods for Cloudfront distribution"
  type = list(string)
  default = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
}

variable "cached_methods" {
  description = "Cached methods for Cloudfront distribution value"
  type = list(string)
  default = ["GET", "HEAD"]
}

variable "default_ttl" {
  description = "Cloudfront default TTL"
  type = number
  default = 3600

  validation {
    condition = tonumber(var.default_ttl) == floor(var.default_ttl)
    error_message = "default_ttl should be an integer!"
  }
  validation {
    condition = var.default_ttl >= 0
    error_message = "default_ttl should be a positive integer!"
  }
}

variable "max_ttl" {
  description = "Cloudfront max TTL"
  type = number
  default = 86400

  validation {
    condition = tonumber(var.max_ttl) == floor(var.max_ttl)
    error_message = "max_ttl should be an integer!"
  }
  validation {
    condition = var.max_ttl >= 0
    error_message = "max_ttl should be a positive integer!"
  }
}
