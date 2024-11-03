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

# -------------- Network parameters ---------------

variable "private_subnets_ids" {
  description = "A list of private subnets ids"
  type        = list(string)
}

# --------------- Cache parameters

variable "cache_replication_group_name" {
  description   = "Cache replication group name"
  type          = string
}

variable "cache_parameter_group_name" {
  description   = "Cache name"
  type          = string
}

variable "cache_parameter_group_family" {
  description   = "Parameter group family"
  type          = string
  default = "redis7"

  validation {
    condition     = contains(["redis2.6", "redis2.8", "redis3.2", "redis4.0", "redis5.0", "redis6.x", "redis7"], var.cache_parameter_group_family)
    error_message = "Valid values for a variable cache_parameter_group_family are: redis2.6 | redis2.8 | redis3.2 | redis4.0 | redis5.0 | redis6.x | redis7"
  }
}

variable "cache_db" {
  description = "Cache DB variable passed through a file variables.auto.tfvars or environment variable TF_cache_db"
  type        = string
}

variable "cache_password" {
  description = "Cache password variable passed through a file secret.tfvars or environment variable TF_cache_password"
  type        = string
  sensitive   = true
}

variable "cache_node_type" {
  description   = "Cache node type"
  type          = string
#   default = "cache.t3.micro"
}

variable "num_cache_clusters" {
  description   = "Num cache clusters"
  type          = number
  default = 2

  validation {
    condition = tonumber(var.num_cache_clusters) == floor(var.num_cache_clusters)
    error_message = "num_cache_clusters should be an integer."
  }

  validation {
    condition = var.num_cache_clusters >= 2
    error_message = "num_cache_clusters should be greater or equal 2."
  }
}

variable "cache_engine" {
  description   = "Cache engine"
  type          = string
  default = "redis"

  validation {
    condition     = contains(["redis", "valkey"], var.cache_engine)
    error_message = "Valid values for a variable cache_engine are: redis | valkey"
  }
}

variable "cache_engine_version" {
  description = "Cache engine version"
  type = string
}

variable "cache_port" {
  description = "Cache port"
  type = number
  default = 6379
}

variable "cache_security_group_id" {
  description = "Cache security group id"
  type = string
}

variable "cache_maintenance_window" {
  description = "cache maintenance window"
  type        = string
  default     = "Sun:02:00-Sun:04:00"
}

variable "cache_snapshot_window" {
  description = "cache snapshot window"
  type        = string
  default = "05:00-09:00"
}

variable "cache_snapshot_retention_limit" {
  description = "cache snapshot retention limit"
  type          = number

  validation {
    condition = tonumber(var.cache_snapshot_retention_limit) == floor(var.cache_snapshot_retention_limit)
    error_message = "cache_snapshot_retention_limit should be an integer."
  }

  validation {
    condition = var.cache_snapshot_retention_limit >= 0
    error_message = "cache_snapshot_retention_limit should be greater or equal 0"
  }
}

variable "cache_multi_az_enabled" {
  description = "Is cache multi_az enabled"
  type        = bool
  default     = false
}

variable "cache_loglevel" {
  description = "cache log level"
  type        = string
  default = "notice"

  validation {
    condition     = contains(["debug", "verbose", "notice", "warning", "nothing"], var.cache_loglevel)
    error_message = "Valid values for a variable cache_loglevel are: debug | verbose | notice | warning | nothing"
  }
}

variable "cache_log_group_name" {
  description = "cache log_group name for CloudWatch"
  type        = string
}

variable "cache_log_retention_in_days" {
  description = "Number of days to keep Elasticache logs in CloudWatch"
  type        = number
  default     = 90

  validation {
    condition     = tonumber(var.cache_log_retention_in_days) == floor(var.cache_log_retention_in_days)
    error_message = "cache_log_retention_in_days should be an integer!"
  }
  validation {
    condition     = var.cache_log_retention_in_days >= 0
    error_message = "cache_log_retention_in_days should be a positive integer!"
  }
}