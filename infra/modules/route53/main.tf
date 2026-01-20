# Ref Existing Hosted Zone
data "aws_route53_zone" "my_domain" {
    name = var.domain_name
    private_zone = var.private_zone
}


# Real DNS record

resource "aws_route53_record" "alb_alias" {
    zone_id = data.aws_route53_zone.my_domain.zone_id
    name = var.domain_name
    type = "A"

    alias {
        name = var.alb_dns_name
        zone_id = var.alb_zone_id
        evaluate_target_health = var.evaluate_target_health
    }
}

# ACM DNS validation records

resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in var.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.my_domain.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}
