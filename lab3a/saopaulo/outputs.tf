# Explanation: Outputs are your mission report—what got built and where to find it.
# output "application_urls" {
#   description = "URLs to test the deployed application"
#   value       = <<EOT
# Home:           http://${aws_instance.liberdade_ec201.public_ip}/
# Initialize DB:  http://${aws_instance.liberdade_ec201.public_ip}/init
# 1st note (GET): http://${aws_instance.liberdade_ec201.public_ip}/add?note=first_note
# 2nd note (GET)  http://${aws_instance.liberdade_ec201.public_ip}/add?note=blue_book_gentlemen
# 3rd note (GET)  http://${aws_instance.liberdade_ec201.public_ip}/add?note=brazil_colombia_capeverde
# 4th note (GET)  http://${aws_instance.liberdade_ec201.public_ip}/add?note=this_is_200k_work
# 5th note (GET)  http://${aws_instance.liberdade_ec201.public_ip}/add?note=liberdade_is_a_success
# List notes:     http://${aws_instance.liberdade_ec201.public_ip}/list
# EOT
# }

output "liberdade_vpc_id" {
  value = aws_vpc.liberdade_vpc01.id
}


####bonus D Add##########
output "liberdade_apex_url_https" {
  value = "https://${var.domain_name}"
}
##### Bonus E Addition ####


# Explanation: Outputs are the mission coordinates — where to point your browser and your blasters.
# output "liberdade_alb_dns_name" {
#   value = aws_lb.liberdade_alb01.dns_name
# }

output "liberdade_app_fqdn" {
  value = "${var.app_subdomain}.${var.domain_name}"
}

# output "liberdade_target_group_arn" {
#   value = aws_lb_target_group.liberdade_tg01.arn
# }
output "liberdade_app_url_https" {
  value = "https://${var.app_subdomain}.${var.domain_name}"
}
output "liberdade_tgw_id" {
  value = aws_ec2_transit_gateway.liberdade_tgw01.id
}