
output "route53_hosted_zone" {
    value = aws_route53_zone.my_domain.zone_id
}

output "acm_validation_fqdns" {
    value = [
        for r in aws_route53_record.acm_validation :
        r.fqdn
    ]
}

output "name_servers" {
    value = aws_route53_zone.my_domain.name_servers
}