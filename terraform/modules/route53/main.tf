resource "aws_route53_zone" "main" {
  name = var.domain_name

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

resource "aws_route53_record" "ml_app" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "ml.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}