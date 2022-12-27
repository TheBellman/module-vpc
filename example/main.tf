# --------------------------------------------------------------------------------
# create a VPC
# --------------------------------------------------------------------------------
module "vpc" {
  /*source = "github.com/TheBellman/module-vpc"*/
  source = "../../module-vpc"
  tags   = var.tags

  vpc_cidr    = var.vpc_cidr
  vpc_name    = var.vpc_name
  ssh_inbound = var.ssh_inbound
}

# --------------------------------------------------------------------------------
# create an instance in a 'public' subnet
# --------------------------------------------------------------------------------
data "aws_ami" "test" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = [local.ami]
  }
}

# TODO - these will probably fail to start because routing isn't necessarily working yet
resource "aws_instance" "public" {
  ami                         = data.aws_ami.test.id
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.public_subnet_id[0]
  vpc_security_group_ids      = [module.vpc.public_sg]
  associate_public_ip_address = true

  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "terminate"

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  tags        = { Name = "Public Test" }
  volume_tags = { Name = "Public Test" }

  user_data = <<EOF
#!/bin/bash
yum update -y -q
EOF
}

resource "aws_instance" "private" {
  ami                    = data.aws_ami.test.id
  instance_type          = "t2.micro"
  subnet_id              = module.vpc.private_subnet_id[0]
  vpc_security_group_ids = [module.vpc.private_sg]

  iam_instance_profile                 = aws_iam_instance_profile.ssm.name
  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "terminate"

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  tags        = { Name = "Private Test" }
  volume_tags = { Name = "Private Test" }

  user_data = <<EOF
#!/bin/bash
yum update -y -q
EOF
}

# --------------------------------------------------------------------------------
# SSM Role for the private instance
# --------------------------------------------------------------------------------
resource "aws_iam_role" "ssm" {
  name               = "${var.vpc_name}-ssm"
  description        = "Role to be assumed by instances to allow access via SSM"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  name = "${var.vpc_name}-private"
  role = aws_iam_role.ssm.name
}
