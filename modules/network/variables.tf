# ---------------- General parameters ----------------

variable "project_name" {
  description   = "Project name"
  type          = string
  default       = "boanerges"
}

variable "environment" {
  description   = "Environment: dev/stage/prod"
  type          = string
  default       = "stage"
}

variable "aws_region" {
  description   = "AWS region"
  type          = string
  default       = "us-east-1"
}

# ---------------- VPC parameters ----------------

variable "cidr_block" {
  description = "A CIDR block of the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.cidr_block, 32))
    error_message = "Must be valid IPv4 CIDR."
  }
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = [ "10.0.10.0/24", "10.0.20.0/24" ]
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = [ "10.0.240.0/24", "10.0.250.0/24" ]
}

variable "vpc_endpoints_sg_id" {
  description   = "An id of a security group for VPC Endpoints"
  type          = string
}


