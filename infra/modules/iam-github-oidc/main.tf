# Create OIDC Provider (who is allowed to knock on AWS's door)

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

# Attach permissions policy ECR (inline) (rulebook of powers)

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
      },
      {
        Effect = "Allow"
        Action = "ecs*"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = "codedeploy:*"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = [
          var.ecs_task_execution_role_arn,
          var.ecs_task_role_arn
        ]
      },
      {
        Effect = "Allow"
        Action = "elasticloadbalancing:Describe*"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = "ssm:GetParameter"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = "cloudwatch:Describe*"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = "logs:DescribeLogGroups"
        Resource = "*"
      }
    ]
  })
}

# Attach permissions policy S3 (inline)

resource "aws_iam_policy" "s3_policy" {
  name = "s3-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [ "s3:ListBucket" ]
        Resource = "${aws_s3_bucket.tf_state.arn}"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = "${aws_kms_key.tf_state.arn}"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.tf_state.arn}/*"
      }
    ]
  })
}

#ECR policy

resource "aws_iam_role_policy_attachment" "github_ecr_attach" {
    role = aws_iam_role.github_actions.name
    policy_arn = aws_iam_policy.github_ecr_policy.arn
}

# S3 state policy

resource "aws_iam_role_policy_attachment" "tf_state" {
  role = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.s3_policy.arn
}
