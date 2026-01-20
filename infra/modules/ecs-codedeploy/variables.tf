# ECS

variable "cluster_name" {
    type = string
    description = "name of ECS cluster"
}

# Code Deploy

variable "codedeploy_role_arn" {
    type = string
    description = "IAM role codedeploy uses to act on my behalf"
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

variable "blue_target_group_arn" {
    type = string 
    description = "ARN of blue target group"
}

variable "green_target_group_arn" {
    type = string
    description = "ARN of green target group"
}

