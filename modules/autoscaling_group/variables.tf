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

# ---------------- Autoscaling parameters --------------

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

variable "autoscale_delete_timeout" {
  description = "Autoscale delete timeout"
  type        = string
  default     = "5m"
}

variable "autoscale_estimated_instance_warmup" {
  description = "Estimated EC2 instance warmup in seconds (used in autoscaling policy)"
  type        = number
  default     = 300

  validation {
    condition     = tonumber(var.autoscale_estimated_instance_warmup) == floor(var.autoscale_estimated_instance_warmup)
    error_message = "autoscale_estimated_instance_warmup should be an integer!"
  }
  validation {
    condition     = var.autoscale_estimated_instance_warmup >= 0
    error_message = "autoscale_estimated_instance_warmup should be a positive integer!"
  }
}

variable "autoscale_avg_cpu_utilization_target" {
  description = "Target value for average CPU utilization of the whole autoscaling group (used in autoscaling policy)"
  type        = number
  default     = 60.0

  validation {
    condition     = var.autoscale_avg_cpu_utilization_target >= 40
    error_message = "autoscale_avg_cpu_utilization_target should be more or equal to 40."
  }

  validation {
    condition     = var.autoscale_avg_cpu_utilization_target <= 80
    error_message = "autoscale_avg_cpu_utilization_target should be less or equal to 80."
  }
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

# ---------------- EC2 parameters ----------------

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

variable "appserver_private_ssh_key_name" {
  description = "Name of the SSH keypair to use with appserver"
  type        = string
  default     = "appserver_ssh_key"
  sensitive   = true
}

variable "admin_public_ssh_keys" {
  description = "List of names of the SSM parameters with admin public ssh keys"
  type        = list(string)
  default     = ["admin_public_ssh_key", "lerkasan_ssh_public_key_bastion"]
}

variable "monitoring_enabled" {
  description = "EC2 instance monitoring"
  type        = bool
  default     = true
}

# ---------------- Logging parameters ----------------

variable "log_group_names" {
  description = "A list of names of log groups to create"
  type        = list(string)
  default     = ["/var/log/spring-boot"]
}

variable "ec2_log_retention_in_days" {
  description = "Number of days to keep EC2 logs in CloudWatch"
  type        = number
  default     = 90

  validation {
    condition     = tonumber(var.ec2_log_retention_in_days) == floor(var.ec2_log_retention_in_days)
    error_message = "ec2_log_retention_in_days should be an integer!"
  }
  validation {
    condition     = var.ec2_log_retention_in_days >= 0
    error_message = "ec2_log_retention_in_days should be a positive integer!"
  }
}

# ---------------- OS parameters --------------------

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
    "ubuntu" = "099720109477" #Canonical
  }
}

# ---------------- Network parameters -------------------

variable "private_subnets_ids" {
  description = "A list of private subnets ids"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC id"
  type        = string
}

# ---------------- CodeDeploy parameters -------------------

variable "codedeploy_deployment_group_arns" {
  description = "ARNs of a CodeDeploy deployment groups"
  type        = list(string)
}

# ---------------- SSM parameters -------------------

variable "ssm_param_db_host_arn" {
  description = "ARN of the SSM parameter for the database host"
  type        = string
}

variable "ssm_param_db_port_arn" {
  description = "ARN of the SSM parameter for the database port"
  type        = string
}

variable "ssm_param_db_name_arn" {
  description = "ARN of the SSM parameter for the database name"
  type        = string
}

variable "ssm_param_db_username_arn" {
  description = "ARN of the SSM parameter for the database username"
  type        = string
}

variable "ssm_param_db_password_arn" {
  description = "ARN of the SSM parameter for the database password"
  type        = string
}

variable "ssm_param_api_secret_key_arn" {
  description = "ARN of the SSM parameter for the Backend API (backend_rds) secret key"
  type        = string
}

variable "ssm_param_cache_secret_key_arn" {
  description = "ARN of the SSM parameter for the Backend cache (backend_redis) secret key"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key used to encrypt the SSM parameters"
  type        = string
}

# ---------------- Security Groups -------------------

variable "ec2_sg_id" {
  description = "Id of the security group for EC2 instance"
  type        = string
}

variable "ec2_connect_endpoint_sg_id" {
  description = "Id of the security group for EC2 instance connect endpoint"
  type        = string
}

variable "alb_target_group_arns" {
  description = "A target group arn of a load balancer"
  type        = list(string)
  default     = []
}

# ------------------ ECR parameters ---------------------

variable "ecr_repository_names" {
  description = "ECR repository names"
  type        = list(string)
  default     = []
}