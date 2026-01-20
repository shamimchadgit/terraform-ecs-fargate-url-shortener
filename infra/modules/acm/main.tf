# ACM Cert
resource "aws_acm_certificate" "main_cert" {
    domain_name = var.domain_name
    validation_method = var.validation_method
    lifecycle {
      create_before_destroy = true
    }
}


# Connect Route53 to ACM (block trf until cert issued)
resource "aws_acm_certificate_validation" "cert_valid" {
    certificate_arn = aws_acm_certificate.main_cert.arn
    validation_record_fqdns = var.validation_record_fqdns
}