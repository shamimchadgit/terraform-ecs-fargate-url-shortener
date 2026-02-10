# Create OIDC Provider 

resource "aws_iam_openid_connect_provider" "github_actions" {
    url = var.url
    client_id_list = [var.client_id_list]
    thumbprint_list = [var.thumbprint_list]
}

# github actions define Trust Policy (list of powers)

data "aws_iam_policy_document" "github_assume_role" {
    statement {
      effect = "Allow"
      principals {
        type = "Federated"
        identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
      }
      actions = ["sts:AssumeRoleWithWebIdentity"]
      condition {
        test = "StringEquals"
        variable = "token.actions.githubusercontent.com:aud"
        values = [var.client_id_list]
      }
      condition {
        test = "StringLike"
        variable = "token.actions.githubusercontent.com:sub"
        values = [var.repo_name]
      }
    }
}

# github actions IAM Role (hat + putting on attached managed policy hat)

resource "aws_iam_role" "github_actions" {
    name = "github-actions-role"
    assume_role_policy = data.aws_iam_policy_document.github_assume_role.json
}

# Attach permissions (inline) (rulebook of powers)

resource "aws_iam_policy" "github_ecr_policy" {
  name = "github-actions-ecr-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories"
        ],
        Resource = [var.ecr_repo_arn]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_ecr_attach" {
    role = aws_iam_role.github_actions.name
    policy_arn = aws_iam_policy.github_ecr_policy.arn
}
