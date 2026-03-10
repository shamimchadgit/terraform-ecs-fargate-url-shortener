# ECS

variable "cluster_name" {
    type = string
    description = "name of ECS cluster"
}

variable "service_name" {
    type = string
    description = "name of ECS service"
}

# ALB

variable "alb_listener_arn" {
    type = string
    description = "ARN for alb listener"
}

variable "alb_test_listener_arn" {
    type = string
    description = "ARN for the alb test listener"
}

variable "blue_target_group_name" {
    type = string 
    description = "Name of blue target group"
}

variable "green_target_group_name" {
    type = string
    description = "Name of green target group"
}

