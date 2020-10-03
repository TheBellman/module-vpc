# --------------------------------------------------------------------------------
# default security groups for use on public ec2 instances
# --------------------------------------------------------------------------------

resource aws_security_group public {
  name        = "${var.vpc_name}_public"
  vpc_id      = aws_vpc.main.id
  description = "Security group for instances in public subnets"
  tags        = merge({ "Name" = "${var.vpc_name} Public" }, var.tags)
}

resource aws_security_group_rule public_ssh_in {
  security_group_id = aws_security_group.public.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.ssh_inbound
}

resource aws_security_group_rule public_http_in {
  security_group_id = aws_security_group.public.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource aws_security_group_rule public_https_in {
  security_group_id = aws_security_group.public.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource aws_security_group_rule public_http_out {
  security_group_id = aws_security_group.public.id
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource aws_security_group_rule public_https_out {
  security_group_id = aws_security_group.public.id
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

# --------------------------------------------------------------------------------
# default security groups for use on private ec2 instances
# --------------------------------------------------------------------------------
resource aws_security_group private {
  name        = "${var.vpc_name}_private"
  vpc_id      = aws_vpc.main.id
  description = "Security group for instances in private subnets"
  tags        = merge({ "Name" = "${var.vpc_name} Private" }, var.tags)
}

resource aws_security_group_rule private_http_in {
  security_group_id = aws_security_group.private.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = aws_subnet.public.*.cidr_block
}

resource aws_security_group_rule private_https_in {
  security_group_id = aws_security_group.private.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = aws_subnet.public.*.cidr_block
}

resource aws_security_group_rule private_http_out {
  security_group_id = aws_security_group.private.id
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource aws_security_group_rule private_https_out {
  security_group_id = aws_security_group.private.id
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
