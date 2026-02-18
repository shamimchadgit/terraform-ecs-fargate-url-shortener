# role ARN for githubs actions

output "github_assume_role_arn" {
    value = aws_iam_role.github_actions.arn
}