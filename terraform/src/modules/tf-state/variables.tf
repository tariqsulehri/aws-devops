variable "bucket_name" {
    description = "Remote S3 Bucket Name"
    type =  string
    validation {
        condition = can(regex("^[a-z0-9]([a-z0-9.-]{1,61}[a-z0-9])?$", var.bucket_name))
        error_message = "Invalid S3 Bucket name: ${bucket_name}"
    }
}