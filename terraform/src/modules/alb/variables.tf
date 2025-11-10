##############################################
# VARIABLES for ALB Module
##############################################

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "env" {
  description = "Deployment environment (e.g. dev, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where ALB is created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security groups to associate with ALB"
  type        = list(string)
}


variable "instance_map" {
  description = "Map of instance names to instance IDs for target group attachment"
  type        = map(string)
}

# variable "instance_ids" {
#   description = "List of backend EC2 instance IDs to attach"
#   type        = list(string)
# }

variable "target_port" {
  description = "Port on which the backend app listens (e.g., 3500)"
  type        = number
  default     = 3500
}

variable "health_check_path" {
  description = "Path for ALB health check"
  type        = string
  default     = "/"
}

variable "enable_https" {
  description = "Enable HTTPS listener"
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "SSL certificate ARN for HTTPS listener"
  type        = string
  default     = ""
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection on ALB"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags to apply to all ALB resources"
  type        = map(string)
  default     = {}
}
