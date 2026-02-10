data "aws_caller_identity" "current" {}

resource "aws_ecr_repository" "url_shortener_app" {
    name = var.repo_name
    image_tag_mutability = "MUTABLE"
    encryption_configuration {
      encryption_type = "KMS"
    }
    image_scanning_configuration {
      scan_on_push = true
    }
}


resource "aws_ecr_lifecycle_policy" "lifecycle" {
    repository = aws_ecr_repository.url_shortener_app.name
    policy = jsonencode({
        rules = [
            {
             rulePriority = 1,
             description = "Expire images older than x days",
             selection = {
                 tagStatus = "untagged"
                 countType = "sinceImagePushed"
                 countUnit = "days"
                 countNumber = var.untagged_count_num
            }
            action = {
                 type = "expire"
            }
            },
            {
              rulePriority = 2
              description = "Keep only latest x images"
              selection = {
                tagStatus = "any"
                countType = "imageCountMoreThan"
                countNumber = var.latest_img
            }
              action = {
                type = "expire"
              }
            }
        ]
    })
}