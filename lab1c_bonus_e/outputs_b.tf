# Explanation: Outputs are the mission coordinates — where to point your browser and your blasters.
output "lab_1c_alb_dns_name" {
  value = aws_lb.lab_1c_alb01.dns_name
}

output "lab_1c_app_fqdn" {
  value = "${var.app_subdomain}.${var.domain_name}"
}

output "lab_1c_target_group_arn" {
  value = aws_lb_target_group.lab_1c_tg01.arn
}

output "lab_1c_acm_cert_arn" {
  value = aws_acm_certificate.snailtek.arn
}

output "lab_1c_waf_arn" {
  value = var.enable_waf ? aws_wafv2_web_acl.lab_1c_waf01[0].arn : null
}

output "lab_1c_dashboard_name" {
  value = aws_cloudwatch_dashboard.lab_1c_dashboard01.dashboard_name
}
output "lab_1c_route53_zone_id" {
  value = data.aws_route53_zone.snailtek.id
}

output "lab_1c_app_url_https" {
  value = "https://${var.app_subdomain}.${var.domain_name}"
}