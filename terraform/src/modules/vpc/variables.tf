##############################################
# VARIABLES - INPUT PARAMETERS FOR VPC MODULE
##############################################

variable "project_name" {
  description = "Name of the project for tagging and naming resources."
  type        = string
}

variable "env" {
  description = "Environment name (production/staging)."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the main VPC."
  type        = string
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones used for subnets (e.g., eu-north-1a, eu-north-1b)."
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets."
  type        = list(string)

  # validation {
  #   condition     = length(var.public_subnet_cidrs) > 0
  #   error_message = "Public subnet CIDRs must be provided and not empty."
  # }
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets."
  type        = list(string)

  # validation {
  #   condition     = length(var.private_subnet_cidrs) > 0
  #   error_message = "Private subnet CIDRs must be provided and not empty."
  # }
}

variable "tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
  default     = {}
}
