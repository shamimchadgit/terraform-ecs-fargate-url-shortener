variable "aws_region" {
    type = string
    description = "AWS region for resources in the backend"
    default = "eu-west-2"
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

variable "aws_iam_role" {
    type = string
    description = "the iam role for my github OIDC"
}