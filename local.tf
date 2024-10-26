locals {
  subnet_cidrs         = cidrsubnets(var.cidr_block, 8, 8, 8, 8)
  public_subnet_cidrs  = slice(local.subnet_cidrs, 0, 2)
  private_subnet_cidrs = slice(local.subnet_cidrs, 2, 4)
  availability_zones   = slice(data.aws_availability_zones.available.names, 0, 2)
}