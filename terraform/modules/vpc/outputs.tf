##############################################
# OUTPUTS - RETURN VALUES FROM VPC MODULE
##############################################

output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.main_vpc.id
}
output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [for s in values(aws_subnet.public_subnets) : s.id]
}
output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [for s in values(aws_subnet.private_subnets) : s.id]
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = [for n in values(aws_nat_gateway.nat_gateways) : n.id]
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.internet_gateway.id
}
