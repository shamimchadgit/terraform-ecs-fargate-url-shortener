# ALB - Variables

variable "load_balancer_type" {
    type = string
    description = "Using an ALB"
    default = "application"
}

variable "internal" {
    type = bool
    description = "Type of ALB"
    default = false
}

variable "subnets" {
    type = list(string)
} 

# TG - Variables

variable "target_type" {
    type = string
    default = "ip"
}

variable "protocol" {
    type = string
    default = "HTTP"
}

variable "vpc_id" {
    type = string
}

variable "alb_sg_id" {
    description = "security group ID for the ALB"
    type = string
}

# Listener 

variable "certificate_arn" {
    type = string
    description = "ACM cert ARN for HTTPS listener"
}

variable "ssl_policy" {
    type = string
    default = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

