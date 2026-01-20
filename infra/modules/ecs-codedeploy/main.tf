resource "aws_codedeploy_app" "url_shortener_app" {
    compute_platform = "ECS"
    name = "${var.cluster_name}-app"
}

resource "aws_codedeploy_deployment_group" "ecs_deploy_group" { # deployment rules
    app_name = aws_codedeploy_app.url_shortener_app.name
    deployment_config_name = "CodeDeployDefault.ECSAllAtOnce" # how tr shifts between b & g
    deployment_group_name = "${var.cluster_name}-cd-group" # name of the enviornment 
    service_role_arn = var.codedeploy_role_arn # IAM role CodeDeploy uses to act on my behalf 

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
      cluster_name = aws_ecs_cluster.main.name
      service_name = aws_ecs_service.svc.name
    }
### Need to check this part properly as not sure what to do with the test_traffic_route 
    load_balancer_info {
      target_group_pair_info {
        prod_traffic_route {
          listener_arns = [var.alb_listener_arn]
        }
        target_group {
          name = var.blue_target_group_arn
        }
        target_group {
          name = var.green_target_group_arn
        }
        test_traffic_route {
          listener_arns = [var.alb_test_listener_arn]
        }
      }
    }   
}