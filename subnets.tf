# --------------------------------------------------------------------------------
# public subnets
# --------------------------------------------------------------------------------

resource "aws_subnet" "public" {
  count                   = local.subnet_count
  vpc_id                  = aws_vpc.main.id
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  cidr_block              = cidrsubnet(var.vpc_cidr, ceil(log(local.subnet_count * 2, 2)), count.index)
  map_public_ip_on_launch = true
  tags                    = merge({ "Name" = "${var.vpc_name} Public" }, var.tags)
}

resource "aws_nat_gateway" "public" {
  allocation_id = aws_eip.igw_ip.id
  subnet_id     = aws_subnet.public[0].id
  tags          = merge({ "Name" = "${var.vpc_name} Public" }, var.tags)
}

#
# public instances route out through the internet gateway
#
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = merge({ "Name" = "${var.vpc_name} public" }, var.tags)
}

resource "aws_route_table_association" "public" {
  count = local.subnet_count

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}


# --------------------------------------------------------------------------------
# private subnets
# --------------------------------------------------------------------------------

resource "aws_subnet" "private" {
  count                   = local.subnet_count
  vpc_id                  = aws_vpc.main.id
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  cidr_block              = cidrsubnet(var.vpc_cidr, ceil(log(local.subnet_count * 2, 2)), local.subnet_count + count.index)
  map_public_ip_on_launch = false
  tags                    = merge({ "Name" = "${var.vpc_name} Private" }, var.tags)
}


# private instances route out via the NAT gateway.
# subnets are implicitly associated with the main route table, so the private subnets don't need to be explicitly associated
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public.id
  }
  tags = merge({ "Name" = "${var.vpc_name} private" }, var.tags)
}


resource "aws_main_route_table_association" "main" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.private.id
    depends_on = [aws_nat_gateway.public, aws_internet_gateway.main]
}
