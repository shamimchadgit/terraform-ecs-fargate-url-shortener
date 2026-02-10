# Create DynamoDb Table
resource "aws_dynamodb_table" "url_shortener" {
    name = var.dynamodb_table_name
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "short_url"

    attribute {
      name = "short_url"
      type = "S"
    } 
    tags = {
      Name = "url_shortener_table"
    }
}

