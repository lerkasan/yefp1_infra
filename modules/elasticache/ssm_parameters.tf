resource "aws_ssm_parameter" "redis_host" {
  name        = join("_", [var.project_name, "redis_host"])
  description = "Cache host"
  type        = "SecureString"
#   key_id      = aws_kms_key.ssm_param_encrypt_key.id
  value       = split(":", aws_elasticache_replication_group.this.primary_endpoint_address)[0]
#   value       = split(":", aws_elasticache_replication_group.this.configuration_endpoint_address)[0]

  tags = {
    Name        = join("_", [var.project_name, "redis_host"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_ssm_parameter" "redis_port" {
  name        = join("_", [var.project_name, "redis_port"])
  description = "Cache port"
  type        = "SecureString"
#   key_id      = aws_kms_key.ssm_param_encrypt_key.id
  value       = split(":", aws_elasticache_replication_group.this.primary_endpoint_address)[1]
#   value       = split(":", aws_elasticache_replication_group.this.configuration_endpoint_address)[1]

  tags = {
    Name        = join("_", [var.project_name, "redis_port"])
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
  value       = var.cache_db

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
  value       = var.cache_password

  tags = {
    Name        = join("_", [var.project_name, "redis_password"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}