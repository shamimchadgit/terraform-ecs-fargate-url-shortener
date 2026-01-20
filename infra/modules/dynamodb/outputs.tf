# Print Table name
output "table_name" {
    value = aws_dynamodb_table.url_shortener.name
}

# Table ARN

output "table_arn" {
    value = aws_dynamodb_table.url_shortener.arn
    description = "anyone outside this module wants to table ARN then this output will be given to them"
}