# --------------------------------------------------------------------------------
# route tables for the two sets of subnets.
# the default (main) route table routes through the NAT gateway
# a custom route table routes through the internet gateway and is attached to the public subnets
# practical upshot is: non-local traffic from/to a private subnet routes through the NAT gateway in a public subnet,
# thence out through the internet gateway. non-local traffic from/to a public subnet goes straight through the internet gateway
# --------------------------------------------------------------------------------
resource aws_route_table igw {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = merge({ "Name" = "${var.vpc_name} igw" }, var.tags)
}

resource aws_route_table ngw {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public.id
  }
  tags = merge({ "Name" = "${var.vpc_name} ngw" }, var.tags)
}

resource aws_main_route_table_association main {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.ngw.id
}

resource aws_route_table_association igw {
  count = local.subnet_count

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.igw.id
}
