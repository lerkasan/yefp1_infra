resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support = true    # necessary for vpc endpoint
  enable_dns_hostnames = true  # necessary for vpc endpoint

  tags = {
    Name        = join("_", [var.project_name, "_vpc"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [ var.vpc_endpoints_sg_id ]
  subnet_ids         = [ for subnet in aws_subnet.private : subnet.id ]

  tags = {
    Name        = join("_", [var.project_name, "_vpc_endpoint_ecr_dkr"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [ var.vpc_endpoints_sg_id ]
  subnet_ids         =  [ for subnet in aws_subnet.private : subnet.id ]

  tags = {
    Name        = join("_", [var.project_name, "_vpc_endpoint_ecr_api"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [ for table in aws_route_table.private : table.id ]

  tags = {
    Name        = join("_", [var.project_name, "_vpc_endpoint_s3"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}
