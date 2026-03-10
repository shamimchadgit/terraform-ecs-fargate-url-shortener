output "ecr_repo_arn" {
    value = aws_ecr_repository.url_shortener_app.arn
}

output "ecr_consumer_repo_arn" {
    value = aws_ecr_repository.analytics_consumer.arn
}

output "ecr_image_url" {
    value = aws_ecr_repository.url_shortener_app.repository_url
}

output "consumer_image_url" {
    value = aws_ecr_repository.analytics-consumer.repository_url
}