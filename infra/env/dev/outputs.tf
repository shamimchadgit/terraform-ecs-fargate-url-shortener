# Task Exec
output "ecs_task_execution_role_arn" {
    value = aws_iam_role.task_execution.arn
}

# Task Role
output "ecs_task_role_arn" {
    value = aws_iam_role.task_role.arn
}

output "kafka_bootstrap" {
    value = "${module.kafka.kafka_private_ip}:9092"
}

# Route53 nameservers for Cloudflare subdomain
output "route53_name_servers" {
  description = "Nameservers for subdomain"
  value       = module.route53.name_servers
}

# ALB DNS name (for testing)
output "alb_dns" {
  description = "DNS name of the ALB"
  value       = module.alb.dns_name
}

# Kafka bootstrap server 
output "kafka_bootstrap" {
  description = "Kafka bootstrap server private IP:port"
  value       = module.kafka.kafka_private_ip
}

# ECS cluster name (needed for CI/CD)
output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.ecs_cluster_name
}

# ECS producer service name
output "ecs_service_name" {
  description = "ECS producer service name"
  value       = module.ecs.ecs_service_name
}

# ECS consumer service name
output "consumer_service_name" {
  description = "Analytics consumer ECS service"
  value       = module.ecs_consumer.consumer_service_name
}

# CodeDeploy application name
output "codedeploy_app_name" {
  description = "CodeDeploy application name"
  value       = module.ecs_codedeploy.codedeploy_app_name
}

# CodeDeploy deployment group name
output "codedeploy_deployment_group" {
  description = "CodeDeploy deployment group name"
  value       = module.ecs_codedeploy.codedeploy_deployment_group
}

# Producer ECR repo URL
output "producer_ecr_repo" {
  description = "ECR repository URL for producer app"
  value       = module.ecr_producer.ecr_image_url
}

# Consumer ECR repo URL
output "consumer_ecr_repo" {
  description = "ECR repository URL for analytics consumer"
  value       = module.ecr_consumer.consumer_image_url
}

# GitHub OIDC role ARN
output "github_assume_role_arn" {
  description = "IAM role ARN assumed by GitHub Actions"
  value       = module.iam_github_oidc.github_assume_role_arn
}

# DynamoDB table name 
output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = module.dynamodb.table_name
}