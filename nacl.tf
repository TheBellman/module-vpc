
# --------------------------------------------------------------------------------
# public subnet NACL
# --------------------------------------------------------------------------------

resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = toset(aws_subnet.public.*.id)
  tags       = merge({ "Name" = "${var.vpc_name} Public" }, var.tags)
}

resource "aws_network_acl_rule" "public_ssh_in" {
  count          = length(var.ssh_inbound)
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100 + count.index
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.ssh_inbound[count.index]
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "public_http_in" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "public_https_in" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 210
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "public_ephemeral_in" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 300
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "public_http_out" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 200
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "public_https_out" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 210
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "public_ephemeral_out" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 300
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}


# --------------------------------------------------------------------------------
# private subnet NACL
# --------------------------------------------------------------------------------

# we still route 80 & 443 (and ephemeral return routes) out, to allow use of yum etc
# from inside the private subnet, however only allow 80 & 443 incomding from the public subnets
# remeber though that non-local traffic from the 'private' subnets routes through the NAT
# gateway, providing anonymity of the instances from outside

resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = toset(aws_subnet.private.*.id)
  tags       = merge({ "Name" = "${var.vpc_name} Private" }, var.tags)
}

resource "aws_network_acl_rule" "private_http_in" {
  count          = local.subnet_count
  network_acl_id = aws_network_acl.private.id
  rule_number    = 200 + count.index
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = element(aws_subnet.private.*.cidr_block, count.index)
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "private_https_in" {
  count          = local.subnet_count
  network_acl_id = aws_network_acl.private.id
  rule_number    = 300 + count.index
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = element(aws_subnet.private.*.cidr_block, count.index)
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "private_ephemeral_in" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 400
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "private_http_out" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 200
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "private_https_out" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 300
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "private_ephemeral_out" {
  count          = local.subnet_count
  network_acl_id = aws_network_acl.private.id
  rule_number    = 400 + count.index
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = element(aws_subnet.private.*.cidr_block, count.index)
  from_port      = 1024
  to_port        = 65535
}
