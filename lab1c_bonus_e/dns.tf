
resource "aws_route53_record" "alb_alias" {
  zone_id = data.aws_route53_zone.snailtek.zone_id
  name    = "app.snailtek.click"
  type    = "A"

  alias {
    name                   = aws_lb.lab_1c_alb01.dns_name
    zone_id                = aws_lb.lab_1c_alb01.zone_id
    evaluate_target_health = true
  }
}