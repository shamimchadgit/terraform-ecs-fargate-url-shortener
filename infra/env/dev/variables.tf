variable "aws_region" {
  type        = string
  description = "AWS region for resources in the backend"
}

# S3

variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket used for state-file"
  default     = "tf-state-url-short-kafka-26"
}


# Kafka 

variable "kafka_instance_type" {
  description = "EC2 instance type for Kafka broker"
  type        = string
  default     = "t3.small"
}

# ACM 

variable "domain_name" {
  type        = string
  description = "Domain name"
}


variable "cluster_name" {
  type        = string
  description = "the setup name of my cluster I want to re-use"
}

# ECS

variable "dynamodb_table_name" {
  type = string
}

variable "repo_name" {
  type = string
}

variable "policy_arn" {
  type = string
}

# Code Deploy

variable "service_name" {
  type        = string
  description = "name of ECS service"
}

variable "blue_target_group_name" {
  type        = string
  description = "Name of blue target group"
}

variable "green_target_group_name" {
  type        = string
  description = "Name of green target group"
}

variable "cidr" {
  type        = string
  description = "CIDR block for my VPC"
}

variable "public_subnets_cidr" {
  type        = list(string)
  description = "CIDR blocks for my 2 public subnets"
}

variable "private_subnets_cidr" {
  type        = list(string)
  description = "CIDR blocks for my 2 private subnets"
}


# ECS / ECR

variable "consumer_repo_name" {
  type        = string
  description = "ECR repository name for analytics consumer"
}

# GitHub OIDC role for CI/CD
variable "github_repo" {
  type        = string
  description = "GitHub repository used for OIDC CI/CD"
}

variable "private_dns_enabled" {
  type    = bool
  default = true
}

variable "enable_dns_support" {
  type    = bool
  default = true
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "ssl_policy" {
  type = string
}

variable "s3_arn" {
  type = string
}

variable "s3_assets_arn" {
  type = string
}

variable "kms_arn" {
  type = string
}

variable "admin_policy_arn" {
    type = string
}