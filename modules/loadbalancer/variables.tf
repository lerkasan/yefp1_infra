# ---------------- General parameters ----------------

variable "project_name" {
  description   = "Project name"
  type          = string
  default       = "boanerges"
}

variable "environment" {
  description   = "Environment: dev/stage/prod"
  type          = string
  default       = "prod"
}

variable "domain_name" {
  description   = "Domain name"
  type          = string
}

# ---------------- Network parameters -------------------

variable "vpc_id" {
  description = "VPC id"
  type        = string
}

variable "public_subnets_ids" {
  description = "A list of public subnets ids"
  type        = list(string)
}

# ----------------- Security parameters ---------------------

variable "lb_sg_id" {
  description = "A security group id of a load balancer"
  type        = string
}

# ----------------- Load balancer parameters -----------------

variable "lb_name" {
  description = "A name of a load balancer"
  type        = string
}

variable "lb_internal" {
  description = "Is a load balancer intenal"
  type        = bool
  default = false
}

variable "lb_type" {
  description = "A type of a load balancer"
  type        = string
  default = "application"

  validation {
    condition     = contains(["application", "network", "gateway"], var.lb_type)
    error_message = "Valid values for a variable lb_type are application, network, gateway."
  }   
}

variable "lb_stickiness_type" {
  description = "A type of stickiness of a target group of a load balancer"
  type        = string
  default = "lb_cookie"

  validation {
    condition     = contains(["lb_cookie", "app_cookie"], var.lb_stickiness_type)
    error_message = "Valid values for a variable lb_stickiness_type are lb_cookie, app_cookie."
  }
}

variable "lb_deregistration_delay" {
  description = "A deregistration delay (in seconds) in a target group of a load balancer"
  type        = number
  default = 300

  validation {
    condition = tonumber(var.lb_deregistration_delay) == floor(var.lb_deregistration_delay)
    error_message = "lb_deregistration_delay should be an integer!"
  }
  validation {
    condition = var.lb_deregistration_delay >= 0
    error_message = "lb_deregistration_delay should be a positive integer!"
  }
}

variable "lb_health_check_path" {
  description = "Health check path"
  type        = string
  default = "/"
}

variable "lb_health_check_healthy_threshold" {
  description = "lb_health_check_healthy_threshold in a health check of a target group of a load balancer"
  type        = number
  default = 3

  validation {
    condition = tonumber(var.lb_health_check_healthy_threshold) == floor(var.lb_health_check_healthy_threshold)
    error_message = "lb_health_check_healthy_threshold should be an integer!"
  }
  validation {
    condition = var.lb_health_check_healthy_threshold >= 0
    error_message = "lb_health_check_healthy_threshold should be a positive integer!"
  }
}

variable "lb_health_check_unhealthy_threshold" {
  description = "lb_health_check_unhealthy_threshold in a health check of a target group of a load balancer"
  type        = number
  default = 3

  validation {
    condition = tonumber(var.lb_health_check_unhealthy_threshold) == floor(var.lb_health_check_unhealthy_threshold)
    error_message = "lb_health_check_unhealthy_threshold should be an integer!"
  }
  validation {
    condition = var.lb_health_check_unhealthy_threshold >= 0
    error_message = "lb_health_check_unhealthy_threshold should be a positive integer!"
  }
}

variable "lb_health_check_interval" {
  description = "lb_health_check_interval in a health check of a target group of a load balancer"
  type        = number
  default = 60

  validation {
    condition = tonumber(var.lb_health_check_interval) == floor(var.lb_health_check_interval)
    error_message = "lb_health_check_interval should be an integer!"
  }
  validation {
    condition = var.lb_health_check_interval >= 0
    error_message = "lb_health_check_interval should be a positive integer!"
  }
}

variable "lb_health_check_timeout" {
  description = "lb_health_check_timeout in a health check of a target group of a load balancer"
  type        = number
  default = 30

  validation {
    condition = tonumber(var.lb_health_check_timeout) == floor(var.lb_health_check_timeout)
    error_message = "lb_health_check_timeout should be an integer!"
  }
  validation {
    condition = var.lb_health_check_timeout >= 0
    error_message = "lb_health_check_timeout should be a positive integer!"
  }
}

variable "lb_cookie_duration" {
  description = "lb_cookie_duration (in seconds) in stickiness of a target group of a load balancer"
  type        = number
  default = 86400

  validation {
    condition = tonumber(var.lb_cookie_duration) == floor(var.lb_cookie_duration)
    error_message = "lb_cookie_duration should be an integer!"
  }
  validation {
    condition = var.lb_cookie_duration >= 0
    error_message = "lb_cookie_durationshould be a positive integer!"
  }
}

variable "website_access_logs_bucket_name" {
  description   = "Bucket name for website access logs "
  type          = string
}
