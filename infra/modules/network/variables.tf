variable "cidr" {
    type = string
    description = "CIDR block for my VPC"
    default = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
    type = list(string)
    description = "CIDR blocks for my 2 public subnets"
    default = [ "10.0.1.0/24", "10.0.2.0/24" ]
}

variable "private_subnets_cidr" {
    type = list(string)
    description = "CIDR blocks for my 2 private subnets"
    default = [ "10.0.101.0/24", "10.0.102.0/24" ]
}

variable "enable_dns_hostnames" {
    type = bool
    default = true 
}

variable "enable_dns_support" {
    type = bool
    default = true 
}

variable "region" {
    type = string
    default = "eu-west-2"
  
}

variable "private_dns_enabled" {
    type = bool
    default = true 
}

# SG for ECS

variable "ecs_sg_name" {
    type = string
    description = "Name of the ECS security group"
    default = "ecs-sg"
  
}

variable "ecs_container_port" {
    type = number
    description = "the incoming traffic the ECS container listens on"
    default = 8080
}