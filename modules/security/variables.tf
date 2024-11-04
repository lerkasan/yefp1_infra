# ---------------- General parameters ----------------

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment: dev/stage/prod"
  type        = string
  default     = "stage"
}

# ---------------- Network parameters -------------------

variable "vpc_id" {
  description = "VPC id"
  type        = string
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks of private subnets"
  type        = list(string)
}

# Don't use it now because a bastion server is not created. Uncomment if using bastion server.
# variable "admin_ip" {
#   description = "Admin/Bastion IP for SSH access rule"
#   type        = string
#   sensitive = true

#   validation {
#     condition     = can(cidrnetmask(var.admin_public_ip))
#     error_message = "Must be a valid IPv4 CIDR block address."
#   }
# }
