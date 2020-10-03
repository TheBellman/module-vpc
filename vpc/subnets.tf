# --------------------------------------------------------------------------------
# public subnets
# --------------------------------------------------------------------------------

resource aws_subnet public {
  count                   = local.subnet_count
  vpc_id                  = aws_vpc.main.id
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  cidr_block              = cidrsubnet(var.vpc_cidr, ceil(log(local.subnet_count * 2, 2)), count.index)
  map_public_ip_on_launch = true
  tags                    = merge({ "Name" = "${var.vpc_name} Public" }, var.tags)
}

resource aws_eip public {
  vpc        = true
  tags       = merge({ "Name" = "${var.vpc_name} Public" }, var.tags)
  depends_on = [aws_internet_gateway.main]
}

resource aws_nat_gateway public {
  allocation_id = aws_eip.public.id
  subnet_id     = aws_subnet.public[0].id
  tags          = merge({ "Name" = "${var.vpc_name} Public" }, var.tags)
}

# --------------------------------------------------------------------------------
# private subnets
# --------------------------------------------------------------------------------

resource aws_subnet private {
  count                   = local.subnet_count
  vpc_id                  = aws_vpc.main.id
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  cidr_block              = cidrsubnet(var.vpc_cidr, ceil(log(local.subnet_count * 2, 2)), local.subnet_count + count.index)
  map_public_ip_on_launch = false
  tags                    = merge({ "Name" = "${var.vpc_name} Private" }, var.tags)
}
