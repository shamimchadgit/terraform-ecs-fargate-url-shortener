locals {
  setup_name = "url-shortener"
  }

# ALB

resource "aws_lb" "alb" {
    name = "${local.setup_name}-alb"
    internal = var.internal
    load_balancer_type = var.load_balancer_type
    security_groups = [var.alb_sg_id]
    subnets = var.subnets
}


# Target Group (blue + green)

resource "aws_lb_target_group" "tg_blue" {
    name = "${local.setup_name}-tg-blue"
    target_type = var.target_type
    port = 8080 # TG needs to match container port
    protocol = var.protocol
    vpc_id = var.vpc_id

    health_check {
      enabled = true
      healthy_threshold = 2
      interval = 30
      matcher = "200"
      path = "/healthz"
      timeout = 10
      unhealthy_threshold = 2
    }

    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_lb_target_group" "tg_green" {
    name = "${local.setup_name}-tg-green"
    target_type = var.target_type
    port = 8080 # TG needs to match container port 
    protocol = var.protocol
    vpc_id = var.vpc_id

    health_check {
      enabled = true
      healthy_threshold = 2
      interval = 30
      matcher = "200"
      path = "/healthz"
      timeout = 10
      unhealthy_threshold = 2
    }

    lifecycle {
      create_before_destroy = true
    }
  
}

# ALB Listener 
resource "aws_lb_listener" "prod_listener" {
    load_balancer_arn = aws_lb.alb.arn
    port = 443
    protocol = "HTTPS"
    ssl_policy = var.ssl_policy
    certificate_arn = var.certificate_arn
    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.tg_blue.arn
    } # blue tg as this is our live version w/ real customer tr
    lifecycle {
      ignore_changes = [ default_action ]
    }
} 

# ALB Test Listener
resource "aws_lb_listener" "test_listener" {
    load_balancer_arn = aws_lb.alb.arn
    port = 9000
    protocol = "HTTP" #doesn't require ACM (HTTPS) as code deploy can't be bad actor 
    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.tg_green.arn
    } # green tg as this is our new version - temp test lane
    lifecycle {
      ignore_changes = [ default_action ]
    }
}

### We use blue tg arn as it is the intial active environment 

# when I add ACM SSL need certifcate_arn and a listener on port 443


