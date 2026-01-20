resource "aws_wafv2_ip_set" "blacklist" {
    name = var.aws_wafv2_ip_set_name
    scope = var.scope_type 
    ip_address_version = var.ip_address_version_type
    addresses = var.addresses
}

resource "aws_wafv2_web_acl" "alb_acl" {
    name = var.aws_wafv2_web_acl_name
    description = "WAF to attach to ALB for protection against bad traffic"
    scope = var.scope_type

    default_action {
      allow {}
    }
  
  rule {
    name = var.rule_one_name
    priority = 1
    
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name = "AWSManagedRulesCommonRuleSet"
        vendor_name = var.vendor_name
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
      metric_name = var.metric_name
      sampled_requests_enabled = var.sampled_requests_enabled
    }
  }

  rule {
    name = var.rule_two_name
    priority = 2

    action {
      block {}
    }
    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.blacklist.arn 
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
      metric_name = var.metric_name_two
      sampled_requests_enabled = var.sampled_requests_enabled
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
    metric_name = var.metric_name_three
    sampled_requests_enabled = var.sampled_requests_enabled

  }
}

resource "aws_wafv2_web_acl_association" "alb_assoc" {
    resource_arn = var.alb_arn
    web_acl_arn = aws_wafv2_web_acl.alb_acl.arn 
}