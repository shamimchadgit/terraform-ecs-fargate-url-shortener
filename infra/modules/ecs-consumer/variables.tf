variable "family" {
    type = string
    default = "analytics-consumer" 
}

variable "execution_role_arn" {
    type = string
}

variable "cluster_name" {
    type = string
}


variable "container_name" {
    type = string
    default = "consumer"
}

variable "container_port" {
    type = number
    default = 8080
  
}

variable "ecr_image_url" {
    type = string
}

variable "essential" {
    type = bool
    default = true
}


variable "kafka_bootstrap" {
    type = string
  
}

variable "table_name" {
    type = string
}

variable "ecs_cluster_id" {
    type = string
}

variable "subnet_ids" {
    type = list(string)
  
}
variable "dynamodb_table_arn" {
    type = string
  
}

variable "consumer_sg_ids" {
    type = list(string)
}

variable "policy_name" {
    type = string
    default = "ecs-consumer-ddb-policy"
}