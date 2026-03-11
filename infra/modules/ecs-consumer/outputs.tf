# ECS consumer service name

output "consumer_service_name" {
  description = "Analytics consumer ECS service"
  value       = aws_ecs_service.consumer.name
}

# Task Execution

output "ecs_task_role_arn" {
    value = aws_iam_role.consumer_task_role.arn
}