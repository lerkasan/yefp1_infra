resource "aws_default_security_group" "default" {
  vpc_id = var.vpc_id
}

resource "aws_security_group" "appserver" {
  name        = join("_", [var.project_name, "_appserver_security_group"])
  description = "security group for application server"
  vpc_id      = var.vpc_id

  tags = {
    Name        = join("_", [var.project_name, "_appserver_sg"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_security_group" "ec2_connect_endpoint" {
  name        = join("_", [var.project_name, "ec2_connect_endpoint_sg"])
  description = "security group for ec2 instance connect endpoint"
  vpc_id      = var.vpc_id

  tags = {
    Name        = join("_", [var.project_name, "ec2_connect_endpoint_sg"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_security_group" "vpc_endpoints" {
  name        = join("_", [var.project_name, "_vpc_endpoints_security_group"])
  description = "Security group for VPC endpoints"
  vpc_id      = var.vpc_id

  tags = {
    Name        = join("_", [var.project_name, "_vpc_endpoints_sg"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_security_group" "alb" {
  name        = join("_", [var.project_name, "_alb_security_group"])
  description = "security group for loadbalancer"
  vpc_id      = var.vpc_id

  tags = {
    Name        = join("_", [var.project_name, "_alb_sg"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_security_group" "database" {
  name        = join("_", [var.project_name, "_db_security_group"])
  description = "Security group for database"
  vpc_id      = var.vpc_id

  tags = {
    Name        = join("_", [var.project_name, "_database_sg"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_security_group" "cache" {
  name        = join("_", [var.project_name, "_cache_security_group"])
  description = "Security group for cache"
  vpc_id      = var.vpc_id

  tags = {
    Name        = join("_", [var.project_name, "_cache_sg"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}


# -------------------- Loadbalancer rules ---------------------------

resource "aws_security_group_rule" "lb_allow_inbound_https_from_all" {
  type              = "ingress"
  description       = "HTTPS ingress"
  from_port         = local.https_port
  to_port           = local.https_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "lb_allow_inbound_http_from_all" {
  type              = "ingress"
  description       = "HTTP ingress"
  from_port         = local.http_port
  to_port           = local.http_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "lb_allow_outbound_to_appserver_backend_rds" {
  type                     = "egress"
  description              = "Backend API egress"
  from_port                = local.backend_rds_app_port
  to_port                  = local.backend_rds_app_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.appserver.id
  security_group_id        = aws_security_group.alb.id
}

resource "aws_security_group_rule" "lb_allow_outbound_to_appserver_backend_redis" {
  type                     = "egress"
  description              = "Backend Redis egress"
  from_port                = local.backend_redis_app_port
  to_port                  = local.backend_redis_app_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.appserver.id
  security_group_id        = aws_security_group.alb.id
}

# -------------------- Appserver rules ---------------------------

resource "aws_security_group_rule" "appserver_backend_rds_allow_inbound_from_lb" {
  type                     = "ingress"
  description              = "Backend API ingress"
  from_port                = local.backend_rds_app_port
  to_port                  = local.backend_rds_app_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.appserver.id
}

resource "aws_security_group_rule" "appserver_backend_redis_allow_inbound_from_lb" {
  type                     = "ingress"
  description              = "Backend Redis ingress"
  from_port                = local.backend_redis_app_port
  to_port                  = local.backend_redis_app_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.appserver.id
}

resource "aws_security_group_rule" "appserver_allow_outbound_https_to_all" {
  type              = "egress"
  description       = "HTTPS egress"
  from_port         = local.https_port
  to_port           = local.https_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.appserver.id
}

resource "aws_security_group_rule" "appserver_allow_outbound_http_to_all" {
  type              = "egress"
  description       = "HTTP egress"
  from_port         = local.http_port
  to_port           = local.http_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.appserver.id
}

resource "aws_security_group_rule" "appserver_allow_inbound_ssh_from_ec2_connect_endpoint" {
  type                     = "ingress"
  description              = "SSH ingress"
  from_port                = local.ssh_port
  to_port                  = local.ssh_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2_connect_endpoint.id
  security_group_id        = aws_security_group.appserver.id
}

resource "aws_security_group_rule" "appserver_allow_outbound_to_database" {
  type        = "egress"
  description = "Postgres egress"
  from_port   = local.postgres_port
  to_port     = local.postgres_port
  protocol    = "tcp"

  source_security_group_id = aws_security_group.database.id
  security_group_id        = aws_security_group.appserver.id
}

resource "aws_security_group_rule" "appserver_allow_outbound_to_elasticache" {
  type        = "egress"
  description = "Redis egress"
  from_port   = local.redis_port
  to_port     = local.redis_port
  protocol    = "tcp"

  source_security_group_id = aws_security_group.cache.id
  security_group_id        = aws_security_group.appserver.id
}

# -------------------- Database rules ---------------------------

resource "aws_security_group_rule" "database_allow_inbound_from_appserver" {
  type        = "ingress"
  description = "Postgres ingress"
  from_port   = local.postgres_port
  to_port     = local.postgres_port
  protocol    = "tcp"

  source_security_group_id = aws_security_group.appserver.id
  security_group_id        = aws_security_group.database.id
}

# -------------------- Cache rules ---------------------------

resource "aws_security_group_rule" "cache_allow_inbound_from_appserver" {
  type        = "ingress"
  description = "Redis ingress"
  from_port   = local.redis_port
  to_port     = local.redis_port
  protocol    = "tcp"

  source_security_group_id = aws_security_group.appserver.id
  security_group_id        = aws_security_group.cache.id
}

# -------------------- EC2 Instance Connect Endpoint rules ---------------------------

resource "aws_security_group_rule" "ec2_connect_endpoint_allow_outbound_ssh_to_appserver" {
  type                     = "egress"
  description              = "SSH egress"
  from_port                = local.ssh_port
  to_port                  = local.ssh_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.appserver.id
  security_group_id        = aws_security_group.ec2_connect_endpoint.id
}

# -------------------- VPC Endpoint rule --------------------------------------------

resource "aws_security_group_rule" "vpc_endpoint_allow_inbound_https_from_private_subnets" {
  type              = "ingress"
  description       = "HTTPS egress"
  from_port         = local.https_port
  to_port           = local.https_port
  protocol          = "tcp"
  cidr_blocks       = var.private_subnet_cidrs
  security_group_id = aws_security_group.vpc_endpoints.id
}
