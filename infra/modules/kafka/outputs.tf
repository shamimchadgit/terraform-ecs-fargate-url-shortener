output "kafka_private_ip" {
    description = "need for ECS producer config"
    value = aws_instance.kafka_broker.private_ip
}
