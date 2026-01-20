# ECS Cluster
output "ecs_cluster_name" {
    value = aws_ecs_cluster.main.name
  
}
output "ecs_cluster_id" {
    value = aws_ecs_cluster.main.id
}

# ECS Service
output "ecs_service_name" {
    value = aws_ecs_service.svc.name
}

# Task Exec
output "ecs_task_execution_role_arn" {
    value = aws_iam_role.task_execution.arn
}

# Task Role
output "ecs_task_role_arn" {
    value = aws_iam_role.task_role.arn
}