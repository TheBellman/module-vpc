# --------------------------------------------------------------------------------
# VPC wide assets
# --------------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge({ "Name" = var.vpc_name }, var.tags)
}

# --------------------------------------------------------------------------------
# internet gateway
# --------------------------------------------------------------------------------

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = merge({ "Name" = var.vpc_name }, var.tags)
}

# TODO fix this name - should be IGW IP
resource "aws_eip" "igw_ip" {
  vpc        = true
  tags       = merge({ "Name" = "${var.vpc_name} Public" }, var.tags)
  depends_on = [aws_internet_gateway.main]
}

# --------------------------------------------------------------------------------
# lookup to find AZ
# --------------------------------------------------------------------------------
data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# --------------------------------------------------------------------------------
# control default NACL and security group
# --------------------------------------------------------------------------------
resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.main.default_network_acl_id
  tags                   = merge({ "Name" = "${var.vpc_name} Default" }, var.tags)
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id
  tags   = merge({ "Name" = "${var.vpc_name} Default" }, var.tags)
}
