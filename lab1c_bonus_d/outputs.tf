# Explanation: Outputs are your mission report—what got built and where to find it.
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

###### Bonus-A Outputs  #####

#Bonus-A outputs (append to outputs.tf)

# Explanation: These outputs prove Chewbacca built private hyperspace lanes (endpoints) instead of public chaos.


output "lab_1c_vpce_ssm_id" {
  value = aws_vpc_endpoint.ssm.id
}

# output "lab_1c_vpce_logs_id" {
#   value = aws_vpc_endpoint.logs.id
# }

output "lab_1c_vpce_secrets_id" {
  value = aws_vpc_endpoint.secrets.id
}

# output "lab_1c_vpce_s3_id" {
#   value = aws_vpc_endpoint.lab_1c_vpce_s3_gw01.id
# }

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


