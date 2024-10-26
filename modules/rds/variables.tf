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

# -------------- Database access parameters ---------------

variable "rds_name" {
  description = "The name of the RDS instance"
  type        = string
  default     = "db"
}

variable "database_engine" {
  description = "database engine"
  type        = string
  default     = "postgres"
}

variable "database_engine_version" {
  description = "database engine version"
  type        = string
  default     = "16.3"
}

variable "database_instance_class" {
  description = "database instance class"
  type        = string
  default     = "db.t3.micro"
}

variable database_storage_type {
  description = "database storage type"
  type        = string
  default     = "gp3"
}

variable database_allocated_storage {
  description = "database allocated storage size in GB"
  type        = number
  default     = 10
}

variable database_max_allocated_storage {
  description = "database max allocated storage size in GB"
  type        = number
  default     = 20
}

variable database_backup_retention_period {
  description = "database backup retention period in days"
  type        = number
  default     = 30
}

variable database_maintenance_window {
  description = "database maintenance window"
  type        = string
  default     = "Sun:02:00-Sun:04:00"
}

variable "database_name" {
  description = "Database name variable passed through a file secret.tfvars or an environment variable TF_database_name"
  type        = string
  sensitive   = true
}

variable "database_username" {
  description = "Database username variable passed through a file secret.tfvars or environment variable TF_database_username"
  type        = string
  sensitive   = true
}

variable "database_password" {
  description = "Database password variable passed through a file secret.tfvars or environment variable TF_database_password"
  type        = string
  sensitive   = true
}

# -------------- IAM role to access SSM parameters ---------------

variable "iam_role_arn" {
  description = "IAM role to access SSM parameters"
  type        = string
}

# -------------- Network parameters ---------------

variable "vpc_id" {
  description = "VPC id"
  type        = string
}

variable "private_subnets_ids" {
  description = "A list of private subnets ids"
  type        = list(string)
}

# -------------- Security parameters ---------------

variable "rds_sg_id" {
  description = "A security group id of a RDS database"
  type        = string
}
