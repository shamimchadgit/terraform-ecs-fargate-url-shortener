data "aws_region" "current" {} # avoid hardcoding region

# attaching pre-existing managed Trust policy 
data "aws_iam_policy_document" "ecs_consumer_task_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# IAM Role (Task Role (task + trust policy))
resource "aws_iam_role" "consumer_task_role" {
    name = var.cluster_name
    assume_role_policy =  data.aws_iam_policy_document.ecs_consumer_task_role_policy.json
}
# Permissions Policy (un-attached)
resource "aws_iam_role_policy" "consumer_task_policy" {
    name = var.policy_name
    role = aws_iam_role.consumer_task_role.id #link to IAM role we made for Task Role

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action   = [
            "dynamodb:GetItem",
            "dynamodb:UpdateItem",
            "dynamodb:PutItem",
          ]
          Resource = [var.dynamodb_table_arn]
        }
      ]
    })
  }


# ECS Task Def
resource "aws_ecs_task_definition" "consumer" {
  family                   = var.family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu    = 256
  memory = 512

  execution_role_arn = var.execution_role_arn
  task_role_arn      = aws_iam_role.consumer_task_role.arn

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.ecr_image_url
      essential = var.essential

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/analytics-consumer"
          awslogs-region        = data.aws_region.current.id
          awslogs-stream-prefix = "ecs"
        }
      }

      environment = [
        {
          name  = "KAFKA_BOOTSTRAP"
          value = var.kafka_bootstrap
        },
        {
          name  = "TABLE_NAME"
          value = var.table_name
        },
        {
          name  = "AWS_REGION"
          value = data.aws_region.current.id
        }
      ]
    }
  ])
}


# ECS Service 

resource "aws_ecs_service" "consumer" {
    name = "analytics-consumer"
    cluster = var.ecs_cluster_id
    task_definition = aws_ecs_task_definition.consumer.arn
    desired_count = 1
    launch_type = "FARGATE"

    deployment_controller {
    type = "ECS"
    }

    network_configuration {
      subnets = var.subnet_ids
      security_groups = var.consumer_sg_ids
    }
}

