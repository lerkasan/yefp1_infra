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

# --------------CodeDeploy parameters ----------------------

variable "codedeploy_app_name" {
  description   = "A CodeDeploy app name"
  type          = string
}

variable deployment_group_name {
  description   = "A deployment group name"
  type          = string
}

variable deployment_config_name {
  description   = "A deployment config name for CodeDeploy on EC2. Valid values are CodeDeployDefault.OneAtATime, CodeDeployDefault.HalfAtATime, CodeDeployDefault.AllAtOnce."
  type          = string
  default = "CodeDeployDefault.OneAtATime"

  validation {
    condition     = contains(["CodeDeployDefault.OneAtATime", "CodeDeployDefault.HalfAtATime", "CodeDeployDefault.AllAtOnce"], var.deployment_config_name)
    error_message = "Valid values for a variable deployment_config_name are CodeDeployDefault.OneAtATime, CodeDeployDefault.HalfAtATime, CodeDeployDefault.AllAtOnce."
  } 
}

variable deployment_type {
  description   = "A deployment type for CodeDeploy on EC2. Valid values are IN_PLACE, BLUE_GREEN"
  type          = string
  default = "IN_PLACE"

  validation {
    condition     = contains(["IN_PLACE", "BLUE_GREEN"], var.deployment_type)
    error_message = "Valid values for a variable deployment_type are IN_PLACE, BLUE_GREEN."
  } 
}

variable "target_group_name" {
  description   = "A target group name of a load balancer"
  type          = string
}

variable "autoscaling_group_name" {
  description   = "An autoscaling group name"
  type          = string
}
