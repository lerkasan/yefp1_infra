module "autoscaling_group" {
  source = "./modules/autoscaling_group"

  ec2_instance_type  = var.ec2_instance_type
  os                 = var.os
  os_architecture    = var.os_architecture
  os_version         = var.os_version
  os_releases        = var.os_releases
  ami_virtualization = var.ami_virtualization
  ami_architectures  = var.ami_architectures
  ami_owner_ids      = var.ami_owner_ids

  appserver_private_ssh_key_name = var.appserver_private_ssh_key_name
  admin_public_ssh_keys          = var.admin_public_ssh_keys
  ec2_log_retention_in_days      = var.ec2_log_retention_in_days
  ecr_repository_names           = var.ecr_repository_names

  aws_region                     = var.aws_region
  vpc_id                         = module.network.vpc_id
  private_subnets_ids            = module.network.private_subnets_ids
  ec2_sg_id                      = module.security.ec2_sg_id
  kms_key_arn                    = module.rds.kms_key_arn
  ssm_param_db_host_arn          = module.rds.ssm_param_db_host_arn
  ssm_param_db_port_arn          = module.rds.ssm_param_db_port_arn
  ssm_param_db_name_arn          = module.rds.ssm_param_db_name_arn
  ssm_param_db_password_arn      = module.rds.ssm_param_db_password_arn
  ssm_param_db_username_arn      = module.rds.ssm_param_db_username_arn
  ssm_param_api_secret_key_arn   = aws_ssm_parameter.django_api_secret_key.arn
  ssm_param_cache_secret_key_arn = aws_ssm_parameter.django_cache_secret_key.arn

  codedeploy_deployment_group_arns = [
    module.codedeploy_backend_rds.deployment_group_arn,
    module.codedeploy_backend_redis.deployment_group_arn
  ]

  ec2_connect_endpoint_sg_id = module.security.ec2_connect_endpoint_sg_id

  alb_target_group_arns = [
    module.loadbalancer.backend_rds_target_group_arn,
    module.loadbalancer.backend_redis_target_group_arn
  ]

  autoscale_min_size                   = var.autoscale_min_size
  autoscale_max_size                   = var.autoscale_max_size
  autoscale_desired_capacity           = var.autoscale_desired_capacity
  autoscale_delete_timeout             = var.autoscale_delete_timeout
  autoscale_estimated_instance_warmup  = var.autoscale_estimated_instance_warmup
  autoscale_avg_cpu_utilization_target = var.autoscale_avg_cpu_utilization_target

  project_name = var.project_name
  environment  = var.environment

  # Dependency is used to ensure that EC2 instance will have Internet access during userdata execution to be able to install packages
  depends_on = [module.network.internet_gateway_id, module.network.nat_gateway_ids]
}

module "loadbalancer" {
  source = "./modules/loadbalancer"

  vpc_id             = module.network.vpc_id
  public_subnets_ids = module.network.public_subnets_ids
  lb_sg_id           = module.security.lb_sg_id

  domain_name                         = var.domain_name
  lb_name                             = var.lb_name
  lb_internal                         = var.lb_internal
  lb_type                             = var.lb_type
  lb_stickiness_type                  = var.lb_stickiness_type
  lb_health_check_path                = var.lb_health_check_path
  lb_health_check_healthy_threshold   = var.lb_health_check_healthy_threshold
  lb_health_check_unhealthy_threshold = var.lb_health_check_unhealthy_threshold
  lb_health_check_interval            = var.lb_health_check_interval
  lb_health_check_timeout             = var.lb_health_check_timeout
  lb_deregistration_delay             = var.lb_deregistration_delay
  lb_cookie_duration                  = var.lb_cookie_duration

  website_access_logs_bucket_name = module.s3_website_access_logs.s3_bucket_domain_name

  project_name = var.project_name
  environment  = var.environment
}

module "rds" {
  source = "./modules/rds"

  vpc_id              = module.network.vpc_id
  private_subnets_ids = module.network.private_subnets_ids
  rds_sg_id           = module.security.rds_sg_id
  iam_role_arn        = module.autoscaling_group.iam_role_arn

  rds_name                         = var.rds_name
  database_engine                  = var.database_engine
  database_engine_version          = var.database_engine_version
  database_instance_class          = var.database_instance_class
  database_storage_type            = var.database_storage_type
  database_allocated_storage       = var.database_allocated_storage
  database_max_allocated_storage   = var.database_max_allocated_storage
  database_backup_retention_period = var.database_backup_retention_period
  database_maintenance_window      = var.database_maintenance_window

  database_name     = var.database_name
  database_password = var.database_password
  database_username = var.database_username

  project_name = var.project_name
  environment  = var.environment
}

module "elasticache" {
  source = "./modules/elasticache"

  cache_replication_group_name   = var.cache_replication_group_name
  cache_parameter_group_name     = var.cache_parameter_group_name
  cache_parameter_group_family   = var.cache_parameter_group_family
  cache_node_type                = var.cache_node_type
  num_cache_clusters             = var.num_cache_clusters
  cache_engine                   = var.cache_engine
  cache_engine_version           = var.cache_engine_version
  cache_port                     = var.cache_port
  cache_db                       = var.cache_db
  cache_password                 = var.cache_password
  private_subnets_ids            = module.network.private_subnets_ids
  cache_security_group_id        = module.security.elacticache_sg_id
  cache_maintenance_window       = var.cache_maintenance_window
  cache_snapshot_window          = var.cache_snapshot_window
  cache_snapshot_retention_limit = var.cache_snapshot_retention_limit
  cache_multi_az_enabled         = var.cache_multi_az_enabled
  cache_loglevel                 = var.cache_loglevel
  cache_log_group_name           = var.cache_log_group_name
  cache_log_retention_in_days    = var.cache_log_retention_in_days

  project_name = var.project_name
  environment  = var.environment
}

module "codedeploy_backend_rds" {
  source = "./modules/codedeploy"

  codedeploy_app_name    = "backend_rds"
  target_group_name      = module.loadbalancer.backend_rds_target_group_name
  autoscaling_group_name = module.autoscaling_group.name

  deployment_group_name  = join("_", [var.deployment_group_name, "backend_rds"])
  deployment_config_name = var.deployment_config_name
  deployment_type        = var.deployment_type

  project_name = var.project_name
  environment  = var.environment
}

module "codedeploy_backend_redis" {
  source = "./modules/codedeploy"

  codedeploy_app_name    = "backend_redis"
  target_group_name      = module.loadbalancer.backend_redis_target_group_name
  autoscaling_group_name = module.autoscaling_group.name

  deployment_group_name  = join("_", [var.deployment_group_name, "backend_redis"])
  deployment_config_name = var.deployment_config_name
  deployment_type        = var.deployment_type

  project_name = var.project_name
  environment  = var.environment
}

module "network" {
  source = "./modules/network"

  aws_region = var.aws_region

  cidr_block          = var.cidr_block
  public_subnets      = local.public_subnet_cidrs
  private_subnets     = local.private_subnet_cidrs
  vpc_endpoints_sg_id = module.security.vpc_endpoints_sg_id

  project_name = var.project_name
  environment  = var.environment
}

module "security" {
  source = "./modules/security"

  vpc_id               = module.network.vpc_id
  private_subnet_cidrs = local.private_subnet_cidrs
  #   admin_public_ip      = var.admin_public_ip

  project_name = var.project_name
  environment  = var.environment
}

module "ecr" {
  source = "./modules/ecr"

  github_repositories      = var.github_repositories_backend
  ecr_repository_names     = var.ecr_repository_names
  ecr_repository_type      = var.ecr_repository_type
  ecr_repository_scan_type = var.ecr_repository_scan_type
  ecr_images_limit         = var.ecr_images_limit
  ecr_user_name            = var.ecr_user_name
  aws_region               = var.aws_region

  project_name = var.project_name
  environment  = var.environment
}

module "s3_website_origin" {
  source = "./modules/s3"

  bucket_name                 = join("-", [var.project_name, "website-origin"])
  is_website                  = true
  s3_object_ownership         = "BucketOwnerEnforced"
  cloudfront_distribution_arn = module.cloudfront.cloudfront_distribution_arn

  project_name = var.project_name
  environment  = var.environment
}

module "s3_website_access_logs" {
  source = "./modules/s3"

  bucket_name         = join("-", [var.project_name, "website-access-logs"])
  is_website          = false
  s3_object_ownership = "BucketOwnerPreferred"

  project_name = var.project_name
  environment  = var.environment
}

module "cloudfront" {
  source = "./modules/cloudfront"

  price_class                     = var.cloudfront_price_class
  domain_name                     = var.domain_name
  github_repositories             = var.github_repositories_frontend
  s3_bucket_arn                   = module.s3_website_origin.s3_bucket_arn
  s3_origin_bucket_domain_name    = module.s3_website_origin.s3_origin_bucket_domain_name
  website_access_logs_bucket_name = module.s3_website_access_logs.s3_bucket_domain_name
  waf_enabled                     = var.cloudfront_waf_enabled
  origin_shield_enabled           = var.cloudfront_origin_shield_enabled
  allowed_methods                 = var.cloudfront_allowed_methods
  default_ttl                     = var.cloudfront_default_ttl
  max_ttl                         = var.cloudfront_max_ttl

  project_name = var.project_name
  environment  = var.environment
}

resource "aws_ssm_parameter" "django_api_secret_key" {
  name        = join("_", [var.project_name, "api_secret_key"])
  description = "Backend API (backend_rds) - Django secret key"
  type        = "SecureString"
  #   key_id      = module.rds.kms_key_id 
  value = var.django_api_secret_key

  tags = {
    Name        = join("_", [var.project_name, "api_secret_key"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_ssm_parameter" "django_cache_secret_key" {
  name        = join("_", [var.project_name, "cache_secret_key"])
  description = "Backend cache (backend_redis) - Django secret key"
  type        = "SecureString"
  #   key_id      = module.rds.kms_key_id
  value = var.django_cache_secret_key

  tags = {
    Name        = join("_", [var.project_name, "cache_secret_key"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_ssm_parameter" "django_cors_allowed_origins" {
  name        = join("_", [var.project_name, "cors_allowed_origins"])
  description = "CORS allowed origins for backend"
  type        = "SecureString"
  value       = var.django_cors_allowed_origins

  tags = {
    Name        = join("_", [var.project_name, "cors_allowed_origins"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}