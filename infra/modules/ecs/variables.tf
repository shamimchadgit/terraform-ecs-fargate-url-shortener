# Permissions Policy Attached (policy arn)
variable "policy_arn" {
    type = string
    default = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# Cluster name
variable "cluster_name" {
    type = string
    description = "Name of my ECS Cluster"
    default = "url-shortener-cluster" 
}

# Task Definition Name

variable "container_name" {
    type = string
    description = "Name of ECS Task Definition"
    default = "ecs-task-definition"
  
}

variable "cpu" {
    type = number
    description = ""
    default = 256
}

variable "memory" {
    type = number
    description = ""
    default = 512
}

# Essential to run service
variable "essential" {
    type = bool
    description = "marking that my app container is essential to run this task def"
    default = true 
}

# image name 
variable "image" {
    type = string
    description = "value"
    default = "123456789012.dkr.ecr.eu-west-2.amazonaws.com/urlshortener:latest" #### Just a placeholder atm as haven't pushed to ECR yet
}

# Network config (subnets)
variable "subnets" {
    type = list(string)
    description = ""
}

# network config (assign public ip)
variable "assign_public_ip" {
    type = bool
    default = false
}

# load balancer (target group arn)
variable "target_group_arn" {
    type = string
    description = "ARN of the Load Balancer target group to associate with the service."
}

# Referencing my dynamodb table

variable "dynamodb_table_arn" {
    type = string  
    description = "Dynamodb table ARN for ECS to locate the resource"
}

variable "service_sg_ids" {
    type = list(string)
}

variable "desired_count" {
    type = number
    default = 2
}

variable "container_port" {
    type = number
    default = 8080
}

variable "table_name" {
    type = string
    description = "dynamodb table name"
}