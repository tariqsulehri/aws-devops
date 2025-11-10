##############################################
# VARIABLES - INPUT PARAMETERS FOR VPC MODULE
##############################################

variable "project_name" {
  description = "Name of the project for tagging and naming resources"
  type        = string
}

variable "env" {
  description = "Environment name (production/staging)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the main VPC"
  type        = string
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones used for subnets (e.g., eu-north-1a, eu-north-1b)"
}

variable "public_subnet_cidrs" {
  type = list(string)
  validation {
    condition     = length(var.public_subnet_cidrs) == length(var.availability_zones)
    error_message = "public_subnet_cidrs length must equal availability_zones length"
  }
}
variable "private_subnet_cidrs" {
  type = list(string)
  validation {
    condition     = length(var.private_subnet_cidrs) == length(var.availability_zones)
    error_message = "private_subnet_cidrs length must equal availability_zones length"
  }
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
