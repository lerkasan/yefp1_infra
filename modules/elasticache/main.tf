resource "aws_elasticache_replication_group" "this" {
  replication_group_id = var.cache_replication_group_name
  description          = "Cache replication group"
  node_type            = var.cache_node_type
  num_cache_clusters   = var.num_cache_clusters
  engine               = var.cache_engine
  engine_version       = var.cache_engine_version
  port                 = var.cache_port
  #   cluster_mode = "enabled"
  automatic_failover_enabled  = true
  preferred_cache_cluster_azs = local.availability_zones
  subnet_group_name           = aws_elasticache_subnet_group.this.name
  security_group_ids          = [var.cache_security_group_id]
  parameter_group_name        = aws_elasticache_parameter_group.this.name
  apply_immediately           = false
  multi_az_enabled            = var.cache_multi_az_enabled
  maintenance_window          = var.cache_maintenance_window
  snapshot_window             = var.cache_snapshot_window
  snapshot_retention_limit    = var.cache_snapshot_retention_limit

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  #   kms_key_id = ""
  auth_token                 = aws_ssm_parameter.cache_password.value
  auth_token_update_strategy = "SET"

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.slow_logs.name
    destination_type = "cloudwatch-logs"
    log_format       = "text"
    log_type         = "slow-log"
  }

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.engine_logs.name
    destination_type = "cloudwatch-logs"
    log_format       = "text"
    log_type         = "engine-log"
  }

  tags = {
    Name        = join("_", [var.project_name, "_cache_replication_group"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_elasticache_subnet_group" "this" {
  name       = join("-", [var.project_name, "cache-subnet-group"])
  subnet_ids = var.private_subnets_ids

  tags = {
    Name        = join("_", [var.project_name, "_cache_subnet_group"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_elasticache_parameter_group" "this" {
  name   = var.cache_parameter_group_name
  family = var.cache_parameter_group_family

  parameter {
    name  = "cluster-enabled"
    value = "no"
  }

  tags = {
    Name        = join("_", [var.project_name, "_cache_parameter_group"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_cloudwatch_log_group" "slow_logs" {
  name              = join("_", [var.project_name, var.cache_log_group_name, "slow_logs"])
  retention_in_days = var.cache_log_retention_in_days

  tags = {
    Name        = join("_", [var.project_name, "_cache_slow_log_group"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_cloudwatch_log_group" "engine_logs" {
  name              = join("_", [var.project_name, var.cache_log_group_name, "engine_logs"])
  retention_in_days = var.cache_log_retention_in_days


  tags = {
    Name        = join("_", [var.project_name, "_cache__engine_log_group"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}