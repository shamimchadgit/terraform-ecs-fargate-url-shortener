output "codedeploy_role_arn" {
    value = aws_codedeploy_app.url_shortener_app.arn 
}

output "codedeploy_app_name" {
  description = "CodeDeploy application name"
  value       = aws_codedeploy_app.url_shortener_app.name
}

output "codedeploy_deployment_group" {
  description = "CodeDeploy deployment group name"
  value       = aws_codedeploy_deployment_group.ecs_deploy_group.app_name
}


