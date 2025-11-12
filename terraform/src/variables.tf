##############################################
# ROOT OUTPUTS - expose useful IDs after apply
##############################################

# output "vpc_id" {
#   description = "VPC ID from vpc module"
#   value       = module.vpc.vpc_id
# }

variable "aws_region" {
  description = "The AWS region where resources will be deployed."
  type        = string
}
variable "project_name" {
  type        = string
  description = "Project name (prefix for resource names)"
  default     = "myproject"
}

# variable "admin_ip" {
#   description = "IP address of the admin to SSH"
#   type        = string
# }
variable "admin_ip" {
  description = "Public IP address allowed to access via SSH"
  type        = string
  # validation {
  #   condition     = can(regex("\\/32$", var.admin_ip))
  #   error_message = "Admin IP must include /32 CIDR suffix."
  # }
}
variable "instance_map" {
  type    = map(string)
  default = {}
}
variable "env" {
  type        = string
  description = "Environment name (production/staging)"
  default     = "production"
}
variable "tags" {
  type        = map(string)
  description = "Common tags to apply"
  default = {
    Owner = "devops"
  }
}

# Network specifics
variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "AZs to use for subnets"
  default     = ["eu-north-1a", "eu-north-1b"]
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs (order matches availability_zones)"
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDRs (order matches availability_zones)"
  default     = ["10.0.2.0/24", "10.0.4.0/24"]
}



variable "app_port" {
  description = "Port that the backend application listens on ALB - backend"
  type        = number
  default     = 3500
}