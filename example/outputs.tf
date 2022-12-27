# --------------------------------------------------------------------------------
# report some interesting facts
# --------------------------------------------------------------------------------
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_arn" {
  value = module.vpc.vpc_arn
}

output "public_subnet" {
  value = module.vpc.public_subnet
}

output "private_subnet" {
  value = module.vpc.private_subnet
}

output "eip_public_address" {
  value = module.vpc.eip_public_address
}

output "public_instance" {
  value = aws_instance.public.public_ip
}

output "private_instance" {
  value = aws_instance.private.private_ip
}