
variable "url" {
    type = string
    description = ""
    default = "https://token.actions.githubusercontent.com"
}

variable "thumbprint_list" {
    type = string
    description = ""
    default = "6938fd4d98bab03faadb97b34396831e3780aea1"
}

variable "client_id_list" {
    type = string
    description = ""
    default = "sts.amazonaws.com"
  
}
# repo name

variable "repo_name" {
    type = string
    description = ""
    default = "repo:your-org/your-repo:*" ### replace w/ actual repo
  
}

# ECR repo ARN

variable "ecr_repo_arn" {
    type = string
    description = "ARN of the ECR repo GitHub Actions will push to"
}

# ECS Task Execution ARN

variable "ecs_task_execution_role_arn" {
    type = string
    description = ""
}

# ECS Task Role ARN

variable "ecs_task_role_arn" {
    type = string
    description = ""
}
  