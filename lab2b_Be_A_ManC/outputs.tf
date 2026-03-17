# Explanation: Outputs are your mission report—what got built and where to find it.
# output "application_urls" {
#   description = "URLs to test the deployed application"
#   value       = <<EOT
# Home:           http://${aws_instance.lab_1c_ec201.public_ip}/
# Initialize DB:  http://${aws_instance.lab_1c_ec201.public_ip}/init
# 1st note (GET): http://${aws_instance.lab_1c_ec201.public_ip}/add?note=first_note
# 2nd note (GET)  http://${aws_instance.lab_1c_ec201.public_ip}/add?note=blue_book_gentlemen
# 3rd note (GET)  http://${aws_instance.lab_1c_ec201.public_ip}/add?note=brazil_colombia_capeverde
# 4th note (GET)  http://${aws_instance.lab_1c_ec201.public_ip}/add?note=this_is_200k_work
# 5th note (GET)  http://${aws_instance.lab_1c_ec201.public_ip}/add?note=lab_1c_is_a_success
# List notes:     http://${aws_instance.lab_1c_ec201.public_ip}/list
# EOT
# }

output "lab_1c_vpc_id" {
  value = aws_vpc.lab_1c_vpc01.id
}

output "lab_1c_public_subnet_ids" {
  value = aws_subnet.lab_1c_public_subnets[*].id
}

output "lab_1c_private_subnet_ids" {
  value = aws_subnet.lab_1c_private_subnets[*].id
}

output "lab_1c_ec2_instance_id" {
  value = aws_instance.lab_1c_ec201.id
}

output "lab_1c_rds_endpoint" {
  value = aws_db_instance.lab1crds.address
}

output "lab_1c_sns_topic_arn" {
  value = aws_sns_topic.lab_1c_sns_topic01.arn
}

output "lab_1c_log_group_name" {
  value = aws_cloudwatch_log_group.lab_1c_log_group01.name
}
output "lab_1c_ec2_Public_address" {
  value = aws_instance.lab_1c_ec201.public_ip
}

output "lab_1c_vpce_ssm_id" {
  value = aws_vpc_endpoint.ssm.id
}

output "lab_1c_vpce_secrets_id" {
  value = aws_vpc_endpoint.secrets.id
}

output "lab_1c_private_ec2_instance_id_bonus" {
  value = aws_instance.lab_1c_ec201.id
}
####bonus D Add##########
output "lab_1c_apex_url_https" {
  value = "https://${var.domain_name}"
}
output "lab_1c_alb_logs_bucket_name" {
  value = var.enable_alb_access_logs ? aws_s3_bucket.lab_1c_alb_logs_bucket01[0].bucket : null
}
##### Bonus E Addition ####
output "lab_1c_waf_log_destination" {
  value = var.waf_log_destination
}

output "lab_1c_waf_cw_log_group_name" {
  value = var.waf_log_destination == "cloudwatch" ? aws_cloudwatch_log_group.lab_1c_waf_log_group01[0].name : null
}
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
output "lab_1c_origin_header_value01" {
  value     = random_password.lab_1c_origin_header_value01.result
  sensitive = true
}


