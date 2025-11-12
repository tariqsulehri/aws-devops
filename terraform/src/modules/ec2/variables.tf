##############################################
# EC2 VARIABLES
##############################################

variable "project_name" {
  description = "Project name for tagging"
  type        = string
}

variable "env" {
  description = "Environment name (e.g. dev, staging, prod)"
  type        = string
}

variable "instance_name" {
  description = "EC2 instance name.."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID to launch the EC2 instance into"
  type        = string
}
variable "security_group_ids" {
  description = "List of security groups to attach to EC2 instance"
  type        = list(string)
}

variable "allocate_eip" {
  description = "Whether to allocate and attach an Elastic IP (true for frontend/public servers)"
  type        = bool
  default     = false
}
variable "instance_type" {
  description = "EC2 instance type for Node.js server"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the existing key pair to SSH into EC2"
  type        = string
}

# variable "ami_id" {
#   description = "AMI ID for EC2 instance (Amazon Linux 2 or Ubuntu)"
#   type        = string
# }

variable "tags" {
  description = "Common tags for resources"
  type        = map(string)
  default     = {}
}
