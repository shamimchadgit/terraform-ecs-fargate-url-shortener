data "aws_caller_identity" "current" {}

resource "aws_ecr_repository" "url_shortener_app" {
    name = "url_shortener_app"
    image_tag_mutability = "MUTABLE"
    encryption_configuration {
      encryption_type = "KMS"
    }
    image_scanning_configuration {
      scan_on_push = true
    }
}

resource "aws_ecr_repository_policy" "myapp" {
    repository = aws_ecr_repository.url_shortener_app.name
    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
              Sid = "CIWorkflow",
                Effect = "Allow",
                Principal = {
                    AWS = [
                        "arn:aws:iam", ###Replace with actual IAM Roles or users that need access 
                        "arn:aws:iam"
                    ]
                    
                }

             Action = [
                "ecr:BatchGetImage", #ref metadata
                "ecr:BatchCheckLayerAvailability", # check layers exist (ECR) before upload
                "ecr:PutImage", #register img manifest (push)
                "ecr:InitiateLayerUpload", #upload img layers
                "ecr:UploadLayerPart", # needed during push (upload chunk of layer)
                "ecr:CompleteLayerUpload", # Finishes upload
                "ecr:DescribeRepositories", #list repos
                "ecr:GetDownloadUrlForLayer", #downloads image layer
                "ecr:GetAuthorizationToken" # lets ECS auth to ECR
            ]
          }
        ]
    })
}

resource "aws_ecr_lifecycle_policy" "lifecycle" {
    repository = aws_ecr_repository.url_shortener_app.name
    policy = jsonencode({
        rules = [
            {
             rulePriority = 1,
             description = "Expire images older than x days ",
             selection = {
                 tagStatus = "untagged",
                 countType = "sinceImagePushed",
                 countUnit = "days",
                 countNumber = var.untagged_count_num
            }
            action = {
                 type = "expire"
            }
            },
            {
              rulePriority = 2,
              description = "Keep latest image for x",
              selection = {
                tagStatus = "any",
                countType = "imageCountMoreThan",
                countNumber = var.latest_img
            }
              action = {
                type = "expire"
              }
            }
        ]
    })
}