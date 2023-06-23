# --------------------------------------------------------------------------------
# create a VPC
# --------------------------------------------------------------------------------
module "vpc" {
  source = "github.com/TheBellman/module-vpc?ref=1.0"
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

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20230325"]
  }
}


resource "aws_instance" "public" {
  ami                         = data.aws_ami.test.id
  instance_type               = "t4g.nano"
  subnet_id                   = module.vpc.public_subnet_id[0]
  vpc_security_group_ids      = [module.vpc.public_sg]
  associate_public_ip_address = true
  depends_on                  = [module.vpc]

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
dnf update -y -q
dnf install postgresql15 -y -q
EOF
}

resource "aws_instance" "private" {
  ami                    = data.aws_ami.test.id
  instance_type          = "t4g.nano"
  subnet_id              = module.vpc.private_subnet_id[0]
  vpc_security_group_ids = [module.vpc.private_sg]
  depends_on             = [module.vpc]

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
dnf update -y -q
EOF
}


resource "aws_instance" "ubuntu" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.public_subnet_id[0]
  vpc_security_group_ids      = [module.vpc.public_sg]
  associate_public_ip_address = true
  depends_on                  = [module.vpc]

  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "terminate"

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  tags        = { Name = "Ubuntu Test" }
  volume_tags = { Name = "Ubuntu Test" }

  user_data = <<EOF
#!/bin/bash
sudo apt -y -q update
sudo apt -y -q upgrade
sudo apt -y -q install postgresql
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
