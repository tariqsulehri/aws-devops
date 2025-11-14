variable "project_name" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Deployment environment (e.g. dev, prod)"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
