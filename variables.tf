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

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cidr_block" {
  description = "A CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.cidr_block, 32))
    error_message = "Must be valid IPv4 CIDR."
  }
}

variable "admin_public_ip" {
  description = "Admin public IP for SSH access rule"
  type        = string
  sensitive   = true

  validation {
    condition     = can(cidrnetmask(var.admin_public_ip))
    error_message = "Must be a valid IPv4 CIDR block address."
  }
}

# -------------------- Autoscaling parameters -----------------------

variable "autoscale_max_size" {
  description = "Autoscaling group max size"
  type        = number
  default     = 2
}

variable "autoscale_min_size" {
  description = "Autoscaling group min size"
  type        = number
  default     = 2
}

variable "autoscale_desired_capacity" {
  description = "Autoscaling group desired capacity"
  type        = number
  default     = 2
}

variable "health_check_grace_period" {
  description = "Health check grace period in seconds"
  type        = number
  default     = 300
}

variable "health_check_type" {
  description = "Health check type"
  type        = string
  default     = "ELB"
}

variable "autoscale_delete_timeout" {
  description = "Autoscale delete timeout"
  type        = string
  default     = "5m"
} # "15m"

# -------------------- EC2 parameters -------------------------------

variable "ec2_instance_type" {
  description = "AWS EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ebs_volume_type" {
  description = "EC2 instance EBS volume type"
  type        = string
  default     = "gp3"
}

variable "ebs_volume_size" {
  description = "EC2 instance EBS volume size"
  type        = number
  default     = 10
}

variable "monitoring_enabled" {
  description = "EC2 instance monitoring"
  type        = bool
  default     = true
}

variable "appserver_private_ssh_key_name" {
  description = "Name of the SSH keypair to use with appserver"
  type        = string
  default     = ""
  sensitive   = true
}

variable "admin_public_ssh_keys" {
  description = "List of names of the SSM parameters with admin public ssh keys"
  type        = list(string)
  default     = []
}

variable "os" {
  description = "AMI OS"
  type        = string
  default     = "ubuntu"
}

variable "os_product" {
  description = "AMI OS product. Values: server or server-minimal"
  type        = string
  default     = "server"
}

variable "os_architecture" {
  description = "OS architecture"
  type        = string
  default     = "amd64"
}

variable "os_version" {
  description = "OS version"
  type        = string
  default     = "22.04"
}

variable "os_releases" {
  description = "OS release"
  type        = map(string)
  default = {
    "22.04" = "jammy"
  }
}

# ---------------- AMI filters ----------------------

variable "ami_virtualization" {
  description = "AMI virtualization type"
  type        = string
  default     = "hvm"
}

variable "ami_architectures" {
  description = "AMI architecture filters"
  type        = map(string)
  default = {
    "amd64" = "x86_64"
  }
}

variable "ami_owner_ids" {
  description = "AMI owner id"
  type        = map(string)
  default = {
    "ubuntu" = "099720109477" # Canonical
  }
}

# -------------------- Database parameters --------------------------

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

variable "database_storage_type" {
  description = "database storage type"
  type        = string
  default     = "gp3"
}

variable "database_allocated_storage" {
  description = "database allocated storage size in GB"
  type        = number
  default     = 10
}

variable "database_max_allocated_storage" {
  description = "database max allocated storage size in GB"
  type        = number
  default     = 20
}

variable "database_backup_retention_period" {
  description = "database backup retention period in days"
  type        = number
  default     = 30
}

variable "database_maintenance_window" {
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

# -------------------- CodeDeploy ------------------------

variable "deployment_group_name" {
  description = "A deployment group name"
  type        = string
}

variable "deployment_config_name" {
  description = "A deployment config name for CodeDeploy on EC2. Valid values are CodeDeployDefault.OneAtATime, CodeDeployDefault.HalfAtATime, CodeDeployDefault.AllAtOnce."
  type        = string
  default     = "CodeDeployDefault.OneAtATime"

  validation {
    condition     = contains(["CodeDeployDefault.OneAtATime", "CodeDeployDefault.HalfAtATime", "CodeDeployDefault.AllAtOnce"], var.deployment_config_name)
    error_message = "Valid values for a variable deployment_config_name are CodeDeployDefault.OneAtATime, CodeDeployDefault.HalfAtATime, CodeDeployDefault.AllAtOnce."
  }
}

variable "deployment_type" {
  description = "A deployment type for CodeDeploy on EC2. Valid values are IN_PLACE, BLUE_GREEN"
  type        = string
  default     = "IN_PLACE"

  validation {
    condition     = contains(["IN_PLACE", "BLUE_GREEN"], var.deployment_type)
    error_message = "Valid values for a variable deployment_type are IN_PLACE, BLUE_GREEN."
  }
}

# ----------------- Load balancer parameters -----------------

variable "domain_name" {
  description = "Domain name"
  type        = string
}

variable "lb_name" {
  description = "A name of a load balancer"
  type        = string
}

variable "lb_internal" {
  description = "Is a load balancer intenal"
  type        = bool
  default     = false
}

variable "lb_type" {
  description = "A type of a load balancer"
  type        = string
  default     = "application"

  validation {
    condition     = contains(["application", "network", "gateway"], var.lb_type)
    error_message = "Valid values for a variable lb_type are application, network, gateway."
  }
}

variable "lb_stickiness_type" {
  description = "A type of stickiness of a target group of a load balancer"
  type        = string
  default     = "lb_cookie"

  validation {
    condition     = contains(["lb_cookie", "app_cookie"], var.lb_stickiness_type)
    error_message = "Valid values for a variable lb_stickiness_type are lb_cookie, app_cookie."
  }
}

variable "lb_deregistration_delay" {
  description = "A deregistration delay (in seconds) in a target group of a load balancer"
  type        = number
  default     = 300

  validation {
    condition     = tonumber(var.lb_deregistration_delay) == floor(var.lb_deregistration_delay)
    error_message = "lb_deregistration_delay should be an integer!"
  }
  validation {
    condition     = var.lb_deregistration_delay >= 0
    error_message = "lb_deregistration_delay should be a positive integer!"
  }
}

variable "lb_health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}

variable "lb_health_check_healthy_threshold" {
  description = "lb_health_check_healthy_threshold in a health check of a target group of a load balancer"
  type        = number
  default     = 3

  validation {
    condition     = tonumber(var.lb_health_check_healthy_threshold) == floor(var.lb_health_check_healthy_threshold)
    error_message = "lb_health_check_healthy_threshold should be an integer!"
  }
  validation {
    condition     = var.lb_health_check_healthy_threshold >= 0
    error_message = "lb_health_check_healthy_threshold should be a positive integer!"
  }
}

variable "lb_health_check_unhealthy_threshold" {
  description = "lb_health_check_unhealthy_threshold in a health check of a target group of a load balancer"
  type        = number
  default     = 3

  validation {
    condition     = tonumber(var.lb_health_check_unhealthy_threshold) == floor(var.lb_health_check_unhealthy_threshold)
    error_message = "lb_health_check_unhealthy_threshold should be an integer!"
  }
  validation {
    condition     = var.lb_health_check_unhealthy_threshold >= 0
    error_message = "lb_health_check_unhealthy_threshold should be a positive integer!"
  }
}

variable "lb_health_check_interval" {
  description = "lb_health_check_interval in a health check of a target group of a load balancer"
  type        = number
  default     = 60

  validation {
    condition     = tonumber(var.lb_health_check_interval) == floor(var.lb_health_check_interval)
    error_message = "lb_health_check_interval should be an integer!"
  }
  validation {
    condition     = var.lb_health_check_interval >= 0
    error_message = "lb_health_check_interval should be a positive integer!"
  }
}

variable "lb_health_check_timeout" {
  description = "lb_health_check_timeout in a health check of a target group of a load balancer"
  type        = number
  default     = 30

  validation {
    condition     = tonumber(var.lb_health_check_timeout) == floor(var.lb_health_check_timeout)
    error_message = "lb_health_check_timeout should be an integer!"
  }
  validation {
    condition     = var.lb_health_check_timeout >= 0
    error_message = "lb_health_check_timeout should be a positive integer!"
  }
}

variable "lb_cookie_duration" {
  description = "lb_cookie_duration (in seconds) in stickiness of a target group of a load balancer"
  type        = number
  default     = 86400

  validation {
    condition     = tonumber(var.lb_cookie_duration) == floor(var.lb_cookie_duration)
    error_message = "lb_cookie_duration should be an integer!"
  }
  validation {
    condition     = var.lb_cookie_duration >= 0
    error_message = "lb_cookie_durationshould be a positive integer!"
  }
}

# ------------------------------- ECR parameters -----------------------------

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

variable "django_secret_key" {
  description = "Django secret key"
  type        = string
  sensitive   = true
}
