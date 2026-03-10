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

# ALB

variable "certificate_arn" {
  type        = string
  description = "ACM cert ARN for HTTPS listener"
}

variable "cluster_name" {
  type        = string
  description = "the setup name of my cluster I want to re-use"
}

variable "subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "alb_sg_id" {
  description = "security group ID for the ALB"
  type        = string
}

# ECS

variable "dynamodb_table_name" {
  type = string
}

variable "dynamodb_table_arn" {
  type        = string
  description = "Dynamodb table ARN for ECS to locate the resource"
}

variable "repo_name" {
  type = string
}

variable "policy_arn" {
  type    = string
  default = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

variable "target_group_arn" {
  type        = string
  description = "ARN of the Load Balancer target group to associate with the service."
}

variable "service_sg_ids" {
  type = list(string)
}

# Code Deploy

variable "service_name" {
  type        = string
  description = "name of ECS service"
}

variable "codedeploy_role_arn" {
  type        = string
  description = "IAM role codedeploy uses to act on my behalf"
}

variable "alb_listener_arn" {
  type        = string
  description = "ARN for alb listener"
}

variable "alb_test_listener_arn" {
  type        = string
  description = "ARN for the alb test listener"
}

variable "blue_target_group_name" {
  type        = string
  description = "Name of blue target group"
}

variable "green_target_group_name" {
  type        = string
  description = "Name of green target group"
}

variable "ecr_repo_arn" {
  type        = string
  description = "ARN of the ECR repo GitHub Actions will push to"
}

variable "ecs_task_execution_role_arn" {
  type        = string
  description = ""
}

variable "ecs_task_role_arn" {
  type        = string
  description = ""
}

variable "s3_arn" {
  type = string
}

variable "kms_arn" {
  type = string
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

variable "domain_validation_options" {
  description = "ACM domain validation options"
  type = list(object({
    domain_name           = string
    resource_record_name  = string
    resource_record_type  = string
    resource_record_value = string
  }))
}

variable "alb_dns_name" {
  description = ""
  type        = string
}

variable "alb_zone_id" {
  description = ""
  type        = string
}

variable "alb_arn" {
  type        = string
  description = "ARN of the ALB to attach this WAF to"
}

# ECS / ECR
variable "app_image_repo_name" {
  type        = string
  description = "ECR repository name for producer app"
}

variable "consumer_image_repo_name" {
  type        = string
  description = "ECR repository name for analytics consumer"
}

# GitHub OIDC role for CI/CD
variable "github_repo" {
  type        = string
  description = "GitHub repository used for OIDC CI/CD"
}

variable "private_dns_enabled" {

}

variable "enable_dns_support" {

}

variable "enable_dns_hostnames" {

}




variable "ssl_policy" {
  type = string
}

variable "policy_name" {
  type = string

}