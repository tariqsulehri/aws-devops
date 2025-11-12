##############################################
# Security Groups - variables.tf
# Purpose: inputs for security groups module
##############################################

variable "project_name" {
  description = "Project or application name used as name prefix"
  type        = string
}

variable "env" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "admin_ip" {
  description = <<-EOT
    Admin public IP in CIDR format allowed to SSH (e.g. 1.2.3.4/32).
    It's recommended to provide a /32 address for a single IP.
  EOT
  type        = string

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}\\/([0-9]|[1-2][0-9]|3[0-2])$", var.admin_ip))
    error_message = "admin_ip must be a valid IPv4 CIDR (for example: 1.2.3.4/32)."
  }
}

variable "app_port" {
  description = "Port that the backend application listens on (ALB -> backend)"
  type        = number
  default     = 3500
}

variable "tags" {
  description = "Map of tags to apply to all security groups"
  type        = map(string)
  default     = {}
}
