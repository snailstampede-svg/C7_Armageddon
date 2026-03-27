# ###################################################
# # SAO PAULO - INFRASTRUCTURE (ALB, DNS, MONITORING)
# ###################################################

# # 1. DNS & CERTIFICATE DATA 
# data "aws_route53_zone" "snailtek" {
#   name         = "snailtek.click"
#   private_zone = false
# }

# resource "aws_acm_certificate" "snailtek" {
#   domain_name       = "snailtek.click"
#   validation_method = "DNS"
#   lifecycle { create_before_destroy = true }
# }

# # 2. DNS VALIDATION HANDSHAKE [cite: 135]
# resource "aws_route53_record" "snailtek_validation" {
#   for_each = {
#     for dvo in aws_acm_certificate.snailtek.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       type   = dvo.resource_record_type
#       record = dvo.resource_record_value
#     }
#   }
#   zone_id = data.aws_route53_zone.snailtek.id
#   name    = each.value.name
#   type    = each.value.type
#   ttl     = 60
#   records = [each.value.record]
# }

# # 3. LOAD BALANCER SECURITY 
# resource "aws_security_group" "liberdade_alb_sg01" {
#   name   = "liberdade-alb-sg01"
#   vpc_id = aws_vpc.liberdade_vpc01.id
# }

# resource "aws_vpc_security_group_ingress_rule" "http" {
#   security_group_id = aws_security_group.liberdade_alb_sg01.id
#   cidr_ipv4 = "0.0.0.0/0"
#   from_port = 80
#   ip_protocol = "tcp"
#   to_port = 80
# }

# resource "aws_vpc_security_group_ingress_rule" "tls" {
#   security_group_id = aws_security_group.liberdade_alb_sg01.id
#   cidr_ipv4 = "0.0.0.0/0"
#   from_port = 443
#   ip_protocol = "tcp"
#   to_port = 443
# }

# # 4. THE LOAD BALANCER [cite: 140, 142]
# resource "aws_lb" "liberdade_alb01" {
#   name               = "liberdade-alb01"
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.liberdade_alb_sg01.id]
#   subnets            = [aws_subnet.liberdade_public_subnet01.id, aws_subnet.liberdade_public_subnet02.id]
# }

# resource "aws_lb_target_group" "liberdade_tg01" {
#   name     = "liberdade-tg01"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.liberdade_vpc01.id
# }

# # 5. LISTENERS (HTTPS) [cite: 146, 148]
# resource "aws_lb_listener" "liberdade_https_listener01" {
#   load_balancer_arn = aws_lb.liberdade_alb01.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
#   certificate_arn   = aws_acm_certificate.snailtek.arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.liberdade_tg01.arn
#   }
# }

# # 6. MONITORING ALARM 
# resource "aws_cloudwatch_metric_alarm" "liberdade_alb_5xx_alarm01" {
#   alarm_name          = "liberdade-alb-5xx-alarm"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = 1
#   threshold           = 5
#   period              = 60
#   statistic           = "Sum"
#   namespace           = "AWS/ApplicationELB"
#   metric_name         = "HTTPCode_ELB_5XX_Count"
#   dimensions          = { LoadBalancer = aws_lb.liberdade_alb01.arn_suffix }
#   alarm_actions       = [aws_sns_topic.liberdade_sns_topic01.arn]
# }

# resource "aws_sns_topic" "liberdade_sns_topic01" {
#   name = "liberdade-sns-topic01"
# }