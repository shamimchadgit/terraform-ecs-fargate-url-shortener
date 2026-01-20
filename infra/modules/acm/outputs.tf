output "certificate_arn" {
    value = aws_acm_certificate.main_cert.arn
}

output "domain_validation_options" {
    value = aws_acm_certificate.main_cert.domain_validation_options
}