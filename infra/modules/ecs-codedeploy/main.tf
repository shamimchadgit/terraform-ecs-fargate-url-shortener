resource "aws_codedeploy_app" "url_shortener_app" {
    compute_platform = "ECS"
    name = "${var.cluster_name}-app"
}

resource "aws_codedeploy_deployment_group" "ecs_deploy_group" { # deployment rules
    app_name = aws_codedeploy_app.url_shortener_app.name
    deployment_config_name = "CodeDeployDefault.ECSCanary10Percent5Minutes" # how tr shifts between b & g (canary)
    deployment_group_name = "${var.cluster_name}-cd-group" # name of the environment 
    service_role_arn = aws_iam_role.codedeploy_role.arn # IAM role CodeDeploy uses to act on my behalf 

    blue_green_deployment_config { # extra rules for b & g deployments 
      deployment_ready_option {
        action_on_timeout = "CONTINUE_DEPLOYMENT" #re-route tr automatically when ver = healthy 
      }
      terminate_blue_instances_on_deployment_success {
        action = "TERMINATE" # terminate blue instances on success
        termination_wait_time_in_minutes = 5
      }
    }
    deployment_style { # ECS only supports b/g
      deployment_option = "WITH_TRAFFIC_CONTROL"
      deployment_type = "BLUE_GREEN" 
    }
    ecs_service { # point code deploy to exact ECS cluster + service 
      cluster_name = var.cluster_name
      service_name = var.service_name
    }

    load_balancer_info {
      target_group_pair_info {
        prod_traffic_route {
          listener_arns = [var.alb_listener_arn]
        }
        target_group {
          name = var.blue_target_group_name
        }
        target_group {
          name = var.green_target_group_name
        }
        test_traffic_route {
          listener_arns = [var.alb_test_listener_arn]
        }
      }
    }   
}

resource "aws_iam_role" "codedeploy_role" {
  name = "url-shortener-codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codedeploy.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_attach" {
  role = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"  
}
