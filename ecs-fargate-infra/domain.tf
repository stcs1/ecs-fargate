resource "aws_acm_certificate" "ecs_domain_cert" {
  domain_name       = "*.${var.domain_name}"
  validation_method = "DNS"

  tags = {
    Name = "${var.ecs_cluster_name}-domain-cert"
  }
}

data "aws_route53_zone" "domain_zone" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "cert_validation" {
  for_each        = { for dvo in aws_acm_certificate.ecs_domain_cert.domain_validation_options : dvo.domain_name => dvo }
  name            = each.value.resource_record_name
  type            = each.value.resource_record_type
  zone_id         = data.aws_route53_zone.domain_zone.zone_id
  records         = [each.value.resource_record_value]
  ttl             = 60
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.ecs_domain_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}