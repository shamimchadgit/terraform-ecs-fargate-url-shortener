# aws_wafv2_ip_set

variable "aws_wafv2_ip_set_name" {
    type = string
    description = "Range of IPs I want to blacklist"
    default = "my-blacklist"
}

variable "scope_type" {
    type = string
    description = "value"
    default = "REGIONAL"

    validation {
      condition = contains(["REGIONAL", "CLOUDFRONT"], var.scope_type)
      error_message = "scope_type must be REGIONAL or CLOUDFRONT"
    } # use guardrail validation to protect against wrong scope usage 
}

variable "ip_address_version_type" {
    type = string
    description = "value"
    default = "IPV4"
}

variable "addresses" {
    type = list(string)
    description = "prevents restricted access for testing and deploying - providing empty default "
    default = []
} 

# aws_wafv2_web_acl

variable "aws_wafv2_web_acl_name" {
    type = string
    description = "Name of web acl"
    default = "url-shortener-waf"
}

variable "vendor_name" {
    type = string 
    description = "name of the vendor"
    default = "AWS"
}

variable "cloudwatch_metrics_enabled" {
    type = bool
    description = "value"
    default = true 
}

variable "metric_name" {
    type = string
    description = "value"
    default = "common-rules"
}

variable "metric_name_two" {
    type = string
    description = "value"
    default = "ip-blacklist"
}

variable "metric_name_three" {
    type = string
    description = "value"
    default = "waf-acl"
}

variable "sampled_requests_enabled" {
    type = bool
    description = "value"
    default = true
}

variable "rule_one_name" {
  type = string
  description = "value"
  default = "AWS-AWSManagedRulesCommonRuleSet"
}

variable "rule_two_name" {
  type = string
  description = "Name of my second rule to allow access but can block IPs by adding to the list"
  default = "IPBlacklist"
}

# Web acl association

variable "alb_arn" {
    type = string
    description = "ARN of the ALB to attach this WAF to"
}