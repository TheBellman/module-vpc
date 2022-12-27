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

locals {
  ami = "amzn2-ami-kernel-5.10-hvm-2.0.20221210.1-x86_64-gp2"
}