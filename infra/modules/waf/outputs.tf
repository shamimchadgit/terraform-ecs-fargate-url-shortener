output "web_acl_arn_output" {
    value = aws_wafv2_web_acl.alb_acl.arn
}