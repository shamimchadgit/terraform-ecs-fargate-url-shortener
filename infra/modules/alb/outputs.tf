output "alb_arn" {
    description = "ARN of the ALB"
    value = aws_lb.alb.arn
}

output "dns_name" {
    description = "URL for where my ALB lives"
    value = aws_lb.alb.dns_name
}

output "zone_id" {
    description = ""
    value = aws_lb.alb.zone_id
  
}

# ALB Listener 

output "alb_listener" {
    description = "ARN for the alb listener"
    value = aws_lb_listener.https.arn
}

output "tg_blue_arn" {
    description = "ARN for live target group (blue)"
    value = aws_lb_target_group.tg_blue.arn
}

output "tg_green_arn" {
    description = "ARN for new target group (green)"
    value = aws_lb_target_group.tg_green.arn
}

# ALB Test listener
output "alb_test_listener" {
    description = "ARN for the alb test listener"
    value = aws_lb_listener.test_listener.arn
}