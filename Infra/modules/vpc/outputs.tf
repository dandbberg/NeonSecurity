output "vpc_id" {
  value = aws_vpc.dberg_vpc.id
}

output "public_subnets" {
  value = aws_subnet.dberg_subnet_public[*].id
}

output "private_subnets" {
  value = aws_subnet.dberg_subnet_private[*].id
}