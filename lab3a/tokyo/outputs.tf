# Explanation: Outputs are your mission report—what got built and where to find it.
# output "application_urls" {
#   description = "URLs to test the deployed application"
#   value       = <<EOT
# Home:           http://${aws_instance.shinjuku_ec201.public_ip}/
# Initialize DB:  http://${aws_instance.shinjuku_ec201.public_ip}/init
# 1st note (GET): http://${aws_instance.shinjuku_ec201.public_ip}/add?note=first_note
# 2nd note (GET)  http://${aws_instance.shinjuku_ec201.public_ip}/add?note=blue_book_gentlemen
# 3rd note (GET)  http://${aws_instance.shinjuku_ec201.public_ip}/add?note=brazil_colombia_capeverde
# 4th note (GET)  http://${aws_instance.shinjuku_ec201.public_ip}/add?note=this_is_200k_work
# 5th note (GET)  http://${aws_instance.shinjuku_ec201.public_ip}/add?note=shinjuku_is_a_success
# List notes:     http://${aws_instance.shinjuku_ec201.public_ip}/list
# EOT
# }

output "shinjuku_vpc_id" {
  value = aws_vpc.shinjuku_vpc01.id
}

output "shinjuku_public_subnet_ids" {
  value = aws_subnet.shinjuku_public_subnets[*].id
}

output "shinjuku_private_subnet_ids" {
  value = aws_subnet.shinjuku_private_subnets[*].id
}

output "shinjuku_ec2_instance_id" {
  value = aws_instance.shinjuku_ec201.id
}

output "shinjuku_rds_endpoint" {
  value = aws_db_instance.lab1crds.address
}

output "shinjuku_sns_topic_arn" {
  value = aws_sns_topic.shinjuku_sns_topic01.arn
}

output "shinjuku_log_group_name" {
  value = aws_cloudwatch_log_group.shinjuku_log_group01.name
}
output "shinjuku_ec2_Public_address" {
  value = aws_instance.shinjuku_ec201.public_ip
}

output "shinjuku_vpce_ssm_id" {
  value = aws_vpc_endpoint.ssm.id
}

output "shinjuku_vpce_secrets_id" {
  value = aws_vpc_endpoint.secrets.id
}

output "shinjuku_private_ec2_instance_id_bonus" {
  value = aws_instance.shinjuku_ec201.id
}
####bonus D Add##########
output "shinjuku_apex_url_https" {
  value = "https://${var.domain_name}"
}
output "shinjuku_alb_logs_bucket_name" {
  value = var.enable_alb_access_logs ? aws_s3_bucket.shinjuku_alb_logs_bucket91[0].bucket : null
}
##### Bonus E Addition ####
output "shinjuku_waf_log_destination" {
  value = var.waf_log_destination
}

output "shinjuku_waf_cw_log_group_name" {
  value = var.waf_log_destination == "cloudwatch" ? aws_cloudwatch_log_group.shinjuku_waf_log_group01[0].name : null
}
# Explanation: Outputs are the mission coordinates — where to point your browser and your blasters.
output "shinjuku_alb_dns_name" {
  value = aws_lb.shinjuku_alb01.dns_name
}

output "shinjuku_app_fqdn" {
  value = "${var.app_subdomain}.${var.domain_name}"
}

output "shinjuku_target_group_arn" {
  value = aws_lb_target_group.shinjuku_tg01.arn
}

output "shinjuku_acm_cert_arn" {
  value = aws_acm_certificate.snailtek.arn
}

output "shinjuku_waf_arn" {
  value = var.enable_waf ? aws_wafv2_web_acl.shinjuku_waf01[0].arn : null
}

output "shinjuku_dashboard_name" {
  value = aws_cloudwatch_dashboard.shinjuku_dashboard01.dashboard_name
}
output "shinjuku_route53_zone_id" {
  value = data.aws_route53_zone.snailtek.id
}

output "shinjuku_app_url_https" {
  value = "https://${var.app_subdomain}.${var.domain_name}"
}
output "shinjuku_origin_header_value01" {
  value     = random_password.shinjuku_origin_header_value01.result
  sensitive = true
}


