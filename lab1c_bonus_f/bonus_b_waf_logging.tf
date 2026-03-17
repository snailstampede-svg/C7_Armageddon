############################################
# Bonus B - WAF Logging (CloudWatch Logs OR S3 OR Firehose)
# One destination per Web ACL, choose via var.waf_log_destination.
############################################

############################################
# Option 1: CloudWatch Logs destination
############################################

# Explanation: WAF logs in CloudWatch are your “blaster-cam footage”—fast search, fast triage, fast truth.
resource "aws_cloudwatch_log_group" "lab_1c_waf_log_group01" {
  count = var.waf_log_destination == "cloudwatch" ? 1 : 0

  # NOTE: AWS requires WAF log destination names start with aws-waf-logs- (students must not rename this).
  name              = "aws-waf-logs-${var.project_name}-webacl01"
  retention_in_days = var.waf_log_retention_days

  tags = {
    Name = "${var.project_name}-waf-log-group01"
  }
}

# Explanation: This wire connects the shield generator to the black box—WAF -> CloudWatch Logs.
resource "aws_wafv2_web_acl_logging_configuration" "lab_1c_waf_logging01" {
  count = var.enable_waf && var.waf_log_destination == "cloudwatch" ? 1 : 0

  resource_arn = aws_wafv2_web_acl.lab_1c_waf01[0].arn
  log_destination_configs = [
    aws_cloudwatch_log_group.lab_1c_waf_log_group01[0].arn
  ]

  # TODO: Students can add redacted_fields (authorization headers, cookies, etc.) as a stretch goal.
  # redacted_fields { ... }

  depends_on = [aws_wafv2_web_acl.lab_1c_waf01]
}


# ############################################
# # Option 2: S3 destination (direct)
# ############################################

# # Explanation: S3 WAF logs are the long-term archive—Chewbacca likes receipts that survive dashboards.
# resource "aws_s3_bucket" "lab_1c_waf_logs_bucket01" {
#   count = var.waf_log_destination == "s3" ? 1 : 0

#   bucket        = "aws-waf-logs-${var.project_name}-${data.aws_caller_identity.current.account_id}"
#   force_destroy = true
#   tags = {
#     Name = "${var.project_name}-waf-logs-bucket01"
#   }
# }

# # Explanation: Public access blocked—WAF logs are not a bedtime story for the entire internet.
# resource "aws_s3_bucket_public_access_block" "lab_1c_waf_logs_pab01" {
#   count = var.waf_log_destination == "s3" ? 1 : 0

#   bucket                  = aws_s3_bucket.lab_1c_waf_logs_bucket01[0].id
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# # Explanation: Connect shield generator to archive vault—WAF -> S3.
# resource "aws_wafv2_web_acl_logging_configuration" "lab_1c_waf_logging_s3_01" {
#   count = var.enable_waf && var.waf_log_destination == "s3" ? 1 : 0

#   resource_arn = aws_wafv2_web_acl.lab_1c_waf01[0].arn
#   log_destination_configs = [
#     aws_s3_bucket.lab_1c_waf_logs_bucket01[0].arn
#   ]

#   depends_on = [aws_wafv2_web_acl.lab_1c_waf01]
# }
