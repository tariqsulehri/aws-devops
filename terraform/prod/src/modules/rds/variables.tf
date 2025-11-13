variable "project_name" {
  description = "Project name"
}

variable "env" {
  description = "Environment production and staging"
  type        = string
}
variable "private_subnet_ids" {
  description = "Private subnet IDs for RDS"
  type        = list(string)
}
variable "security_group_ids" {
  description = "Security groups for RDS access"
  type        = list(string)
}
variable "db_name" {
  default = "appdb"
}
variable "username" {
  default = "admin"
}
variable "password" {
  description = "Master password for RDS"
  sensitive   = true
}
variable "engine_version" {
  default = "8.0"
}
variable "instance_class" {
  default = "db.t3.micro"
}
variable "allocated_storage" {
  default = 20
}
variable "max_allocated_storage" {
  default = 100
}
variable "multi_az" {
  default = false
}
variable "backup_retention_period" {
  default = 7
}
variable "port" {
  default = 3306
}
variable "tags" {
  type    = map(string)
  default = {}
}
