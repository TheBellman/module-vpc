# --------------------------------------------------------------------------------
# terraform runtime definitions
# --------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.13.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.7.0"
    }
  }
}

provider aws {
  version = ">= 3.7.0"
  region  = var.aws_region
  profile = var.aws_profile
}

# --------------------------------------------------------------------------------
# variables to inject from terraform.tfvars or commandline
# --------------------------------------------------------------------------------
variable aws_region {
  type = string
}

variable aws_account_id {
  type = string
}

variable aws_profile {
  type = string
}

variable tags {
  type = map(string)
}

variable vpc_cidr {
  type = string
}

variable vpc_name {
  type = string
}

variable ssh_inbound {
  type = list(string)
}
# --------------------------------------------------------------------------------
# create a VPC
# --------------------------------------------------------------------------------
module vpc {
  source = "../vpc"
  tags   = var.tags

  vpc_cidr    = var.vpc_cidr
  vpc_name    = var.vpc_name
  ssh_inbound = var.ssh_inbound
}

# --------------------------------------------------------------------------------
# create an instance in a 'public' subnet
# --------------------------------------------------------------------------------
data aws_ami test {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.20200917.0-x86_64-gp2"]
  }
}

resource aws_instance public {
  ami                    = data.aws_ami.test.id
  instance_type          = "t2.micro"
  subnet_id              = module.vpc.public_subnet_id[0]
  vpc_security_group_ids = [module.vpc.public_sg]

  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "terminate"

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  tags        = { Name = "Public Test", Owner = "Robert", Client = "Little Dog Digital", Project = "VPC Module Test" }
  volume_tags = { Name = "Public Test", Owner = "Robert", Client = "Little Dog Digital", Project = "VPC Module Test" }

  user_data = <<EOF
#!/bin/bash
yum update -y -q
EOF
}

resource aws_instance private {
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

  tags        = { Name = "Private Test", Owner = "Robert", Client = "Little Dog Digital", Project = "VPC Module Test" }
  volume_tags = { Name = "Private Test", Owner = "Robert", Client = "Little Dog Digital", Project = "VPC Module Test" }

  user_data = <<EOF
#!/bin/bash
yum update -y -q
EOF
}

# --------------------------------------------------------------------------------
# SSM Role for the private instance
# --------------------------------------------------------------------------------
resource aws_iam_role ssm {
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

resource aws_iam_role_policy_attachment ssm {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource aws_iam_instance_profile ssm {
  name = "${var.vpc_name}-private"
  role = aws_iam_role.ssm.name
}
# --------------------------------------------------------------------------------
# report some interesting facts
# --------------------------------------------------------------------------------
output vpc_id {
  value = module.vpc.vpc_id
}

output vpc_arn {
  value = module.vpc.vpc_arn
}

output public_subnet {
  value = module.vpc.public_subnet
}

output private_subnet {
  value = module.vpc.private_subnet
}

output eip_public_address {
  value = module.vpc.eip_public_address
}

output public_instance {
  value = aws_instance.public.public_ip
}

output private_instance {
  value = aws_instance.private.private_ip
}
