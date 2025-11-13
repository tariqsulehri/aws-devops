variable "bucket_name" {
  description = "S3 bucket name for storing Terraform state"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9.-]{1,61}[a-z0-9])?$", var.bucket_name))
    error_message = "Invalid bucket name. Must be 3–63 characters, lowercase letters, numbers, hyphens, or dots, starting and ending with a letter or number."
  }
}
variable "force_destroy" {
  description = "Allow force deletion of bucket (use false for production)"
  type        = bool
  default     = false
}
variable "dynamodb_table_name" {
  description = "Name of DynamoDB table for state locking"
  type        = string
  default     = "terraform-state-locking"
}