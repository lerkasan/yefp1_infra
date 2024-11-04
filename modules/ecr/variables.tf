variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ecr_repository_names" {
  description = "ECR repository names"
  type        = list(string)
  default     = []
}

variable "ecr_repository_type" {
  description = "ECR repository type"
  type        = string
  default     = "private"

  validation {
    condition     = contains(["private", "public"], var.ecr_repository_type)
    error_message = "Valid values for a variable ecr_repository_type are private, public."
  }
}

variable "ecr_repository_scan_type" {
  description = "ecr_repository_scan_type (BASIC or ENHANCED)"
  type        = string
  default     = "BASIC"

  validation {
    condition     = contains(["BASIC", "ENHANCED"], var.ecr_repository_scan_type)
    error_message = "Valid values for a variable ecr_repository_scan_type are BASIC, ENHANCED."
  }
}

variable "ecr_images_limit" {
  description = "Number of images to keep in an ECR repository"
  type        = number
  default     = 5

  validation {
    condition     = tonumber(var.ecr_images_limit) == floor(var.ecr_images_limit)
    error_message = "ecr_images_limit should be an integer!"
  }
  validation {
    condition     = var.ecr_images_limit >= 0
    error_message = "ecr_images_limit should be a positive integer!"
  }
}

variable "ecr_user_name" {
  description = "A name of a user with access to ECR"
  type        = string
  sensitive   = true
}

variable "github_repositories" {
  description = "Github repositories included in trust policy for Github OIDC"
  type        = list(string)
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment: dev/stage/prod"
  type        = string
  default     = "stage"
}