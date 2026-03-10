# ECS consumer service name

output "consumer_service_name" {
  description = "Analytics consumer ECS service"
  value       = aws_ecs_service.consumer.name
}