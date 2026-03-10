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