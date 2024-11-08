resource "aws_ssm_parameter" "cache_host" {
  name        = join("_", [var.project_name, "cache_host"])
  description = "Cache host"
  type        = "SecureString"
  #   key_id      = aws_kms_key.ssm_param_encrypt_key.id
  value = split(":", aws_elasticache_replication_group.this.primary_endpoint_address)[0]
  # If cluster mode is enabled for ElastiCache than use cluster will have only configuration_endpoint_address
  #   value       = split(":", aws_elasticache_replication_group.this.configuration_endpoint_address)[0] 

  tags = {
    Name        = join("_", [var.project_name, "cache_host"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_ssm_parameter" "cache_port" {
  name        = join("_", [var.project_name, "cache_port"])
  description = "Cache port"
  type        = "SecureString"
  #   key_id      = aws_kms_key.ssm_param_encrypt_key.id
  value = var.cache_port
  # If cluster mode is enabled for ElastiCache than use cluster will have only configuration_endpoint_address
  #   value       = split(":", aws_elasticache_replication_group.this.configuration_endpoint_address)[1]

  tags = {
    Name        = join("_", [var.project_name, "cache_port"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_ssm_parameter" "cache_db" {
  name        = join("_", [var.project_name, "cache_db"])
  description = "Cache db"
  type        = "SecureString"
  #   key_id      = aws_kms_key.ssm_param_encrypt_key.id
  value = var.cache_db

  tags = {
    Name        = join("_", [var.project_name, "cache_db"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_ssm_parameter" "cache_password" {
  name        = join("_", [var.project_name, "cache_password"])
  description = "Cache password"
  type        = "SecureString"
  #   key_id      = aws_kms_key.ssm_param_encrypt_key.id
  value = var.cache_password

  tags = {
    Name        = join("_", [var.project_name, "redis_password"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}