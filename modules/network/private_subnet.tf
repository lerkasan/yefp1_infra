# ----------------  PRIVATE NETWORK -----------------

resource "aws_subnet" "private" {
  for_each                = toset(local.availability_zones)

  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.value
  cidr_block              = var.private_subnets[index(local.availability_zones, each.value)]

  tags = {
    Name        = join("_", [var.project_name, "_private_subnet"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_eip" "this" {
  for_each   = aws_subnet.public

  domain     = "vpc"

  tags = {
    Name        = join("_", [var.project_name, "_nat_gw_eip"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_nat_gateway" "this" {
  for_each          = aws_subnet.public

  connectivity_type = "public"
  subnet_id         = aws_subnet.public[each.key].id
  allocation_id     = aws_eip.this[each.key].id

  tags = {
    Name        = join("_", [var.project_name, "_nat_gw"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_route_table" "private" {
  for_each     = aws_nat_gateway.this

  vpc_id       = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = each.value.id
  }

  tags = {
    Name        = join("_", [var.project_name, "_private_rt"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

