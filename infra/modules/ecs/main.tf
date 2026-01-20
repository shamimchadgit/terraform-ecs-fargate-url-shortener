# AWS IAM Role (Execution Role (task + trust policy))
resource "aws_iam_role" "task_execution" {
    name = "${var.cluster_name}-ecs-task-execution"
    assume_role_policy = data.aws_iam_policy_document.ecs_task_role_policy.json # both roles assumed by ECS task during runtime (same wearer) different intent in use afterwards - hence, execution and task role share same assume role policy
}
# attaching pre-existing managed Trust policy 
data "aws_iam_policy_document" "ecs_task_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
# Permissions Policy (Attached)
resource "aws_iam_role_policy_attachment" "execution_role" {
    role = aws_iam_role.task_execution.name
    policy_arn = var.policy_arn
}

# 2nd IAM Role (Task Role (task + trust policy))
resource "aws_iam_role" "task_role" {
    name = "${var.cluster_name}-ecs-task-role"
    assume_role_policy =  data.aws_iam_policy_document.ecs_task_role_policy.json
}
# Permissions Policy (un-attached)
resource "aws_iam_role_policy" "task_policy" {
    name = "${var.cluster_name}-inline-policy"
    role = aws_iam_role.task_role.id #link to IAM role we made for Task Role

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action   = [
            "dynamodb:GetItem", 
            "dynamodb:PutItem",
          ]
          Resource = var.dynamodb_table_arn
        }
      ]
    })
  }

# ECS Cluster Definition
resource "aws_ecs_cluster" "main" {
  name = var.cluster_name # Required
  }

# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.cluster_name}-task" # required
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc" #give each task it's own ENI inside my VPC
  cpu                      = data.aws_ssm_parameter.task_cpu.value # required for fargate
  memory                   = data.aws_ssm_parameter.task_memory.value # required for Fargate
  execution_role_arn = aws_iam_role.task_execution.arn # hook IAM execution role arn
  task_role_arn = aws_iam_role.task_role.arn # hook IAM task role arn
  
  container_definitions    = jsonencode( #required - converts HCL object (what i wrote above) to JSN for AWS to consume 
[
  {
    name = var.task_def_name,
    image = var.image,
    cpu = data.aws_ssm_parameter.task_cpu.value
    memory = data.aws_ssm_parameter.task_memory.value,
    essential = var.essential
    portMappings = [{
        containerPort = var.container_port
        hostPort = var.container_port
        protocol = "tcp"
    }
  ]
  logConfiguration = {
    logDriver = "awslogs"
    options = {
        awslogs-group = "/ecs/${var.cluster_name}"
        awslogs-region = data.aws_region.current.name
        awslogs-stream-prefix = "ecs"
    }
    depends_on = [
        aws_iam_role_policy_attachment.execution_role,
        aws_iam_role_policy.task_policy
    ]
  }
  environment = [{
    name = "TABLE_NAME"
    value = var.table_name
  },
  {
    name = "AWS_REGION"
    value = data.aws_region.current.name
  }]
  }
])
}

data "aws_region" "current" {} # avoid hardcoding region

resource "aws_cloudwatch_log_group" "ecs" {
    name = "/ecs/${var.cluster_name}"
    retention_in_days = 7
}

# ECS Service 
resource "aws_ecs_service" "svc" {
  name            = "${var.cluster_name}-svc"
  cluster         = aws_ecs_cluster.main.id #id because need to ref name
  task_definition = aws_ecs_task_definition.app.arn #arn not id as task def can have multiple revisions under same family name 
  desired_count   = var.desired_count
  platform_version = "LATEST"
  launch_type = "FARGATE"

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
    subnets = var.subnets
    security_groups = var.service_sg_ids
    assign_public_ip = var.assign_public_ip
}
  load_balancer {
    target_group_arn = var.target_group_arn #req'd for ALB
    container_name = var.task_def_name # required
    container_port = var.container_port # required
  }
  lifecycle {
    ignore_changes = [ 
        task_definition,
        load_balancer,
        desired_count,
        deployment_controller,
        platform_version
     ]
  }
}

# SSM Parameter 
data "aws_ssm_parameter" "task_cpu" {
    name = aws_ssm_parameter.task_cpu.name
}
data "aws_ssm_parameter" "task_memory" {
    name = aws_ssm_parameter.task_memory.name
}

resource "aws_ssm_parameter" "task_cpu" {
    name = "/ecs/${var.cluster_name}"
    type = "String"
    value = tostring(var.cpu)
}

resource "aws_ssm_parameter" "task_memory" {
    name = "/ecs/${var.cluster_name}"
    type = "String"
    value = toString(var.memory)
}

### Might include a depends_on (race condition) as ECS task def depends on other factors: IAM, CW logs, SSM param


