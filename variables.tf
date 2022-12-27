locals {
  # This is used to divide the VPC subnet IP range into 2 * (number of AZ) subranges
  subnet_count = length(data.aws_availability_zones.available.names)
}

variable "tags" {
  type = map(string)
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
