output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_arn" {
  description = "VPC ARN"
  value       = aws_vpc.main.arn
}

output "public_subnet" {
  description = "CIDR blocks for the public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "public_subnet_id" {
  description = "ID for the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet" {
  description = "CIDR blocks for the private subnets"
  value       = aws_subnet.private[*].cidr_block
}

output "private_subnet_id" {
  description = "ID for the private subnets"
  value       = aws_subnet.private[*].id
}

output "eip_public_address" {
  description = "NAT Gateway public address"
  value       = aws_eip.public.public_ip
}

output "eip_private_address" {
  description = "NAT Gateway private address"
  value       = aws_eip.public.private_ip
}

output "public_sg" {
  description = "ID of the Public security group"
  value       = aws_security_group.public.id
}

output "private_sg" {
  description = "ID of the Private security group"
  value       = aws_security_group.private.id
}

output "public_nacl_id" {
  description = "ID of the NACL attached to the public subnets"
  value       = aws_network_acl.public.id
}
