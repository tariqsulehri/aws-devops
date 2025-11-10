#############################################
# OUTPUTS - Security Groups
# Description:
# These outputs expose key attributes (ID, ARN, and Name)
# for each security group to be reused across environments.
##############################################


##############################################
# OUTPUTS: Expose Security Group Details
##############################################
# output "vpc_id" {
#   description = "VPC ID"
#   value       = module.vpc.vpc_id
# }

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

# output "frontend_instance_id" {
#   value = module.frontend_ec2.instance_id
# }

# output "backend_instance_id" {
#   value = module.backend_ec2.instance_id
# }

# output "rds_endpoint" {
#   value = module.rds.rds_endpoint
# }