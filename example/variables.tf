# --------------------------------------------------------------------------------
# variables to inject from terraform.tfvars or commandline
# --------------------------------------------------------------------------------
variable "aws_region" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "aws_profile" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "ssh_inbound" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}

# Amazon Linux 2023 AMI 2023.0.20230503.0 x86_64 HVM kernel-6.1
#    al2023-ami-2023.0.20230503.0-kernel-6.1-x86_64
# Amazon Linux 2023 AMI 2023.0.20230503.0 arm64 HVM kernel-6.1
#    al2023-ami-2023.0.20230503.0-kernel-6.1-arm64
locals {
  ami = "al2023-ami-2023.0.20230503.0-kernel-6.1-arm64"
}

