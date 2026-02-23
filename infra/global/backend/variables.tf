variable "aws_region" {
    type = string
    description = "AWS region for resources in the backend"
}

variable "bucket_name" {
    type = string
    description = "Name of the S3 bucket used for state-file"
}

variable "prevent_destroy" {
    type = bool
    default = true
}

variable "status" {
    type = string
    default = "Enabled"
}

variable "bucket_key_enabled" {
    type = bool
    description = "To use S3 bucket keys for SSE-KMS"
    default = true
}
