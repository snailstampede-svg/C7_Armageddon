############################################
# Bonus B - ALB (Public) -> Target Group (Private EC2) + TLS + WAF + Monitoring
############################################

locals {
  # Explanation: This is the roar address — where the galaxy finds your app.
  lab_1c_fqdn = "${var.app_subdomain}.${var.domain_name}"
}



#########################
# Route53 Data Lookup   #
#########################

# This searches for the existing zone instead of creating a new one
data "aws_route53_zone" "snailtek" {
  name         = "snailtek.click"
  private_zone = false
}
###################
# ACM Certificate #
###################
#terraform apply -target=aws_acm_certificate.snailtek
# create cert first to prevent duplication error in TF when trying to create certificates.
resource "aws_acm_certificate" "snailtek" {
  domain_name               = "snailtek.click"
  subject_alternative_names = ["*.snailtek.click"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
##################
# DNS Validation #
##################
resource "aws_route53_record" "snailtek_validation" {
  for_each = {
    for dvo in aws_acm_certificate.snailtek.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }
  allow_overwrite = true
  zone_id         = data.aws_route53_zone.snailtek.id
  name            = each.value.name
  type            = each.value.type
  ttl             = 60
  records         = [each.value.record]
}

resource "aws_acm_certificate_validation" "snailtek" {
  certificate_arn = aws_acm_certificate.snailtek.arn
  validation_record_fqdns = [
    for record in aws_route53_record.snailtek_validation :
    record.fqdn
  ]
}
# ############################################
# # Security Group: ALB
# ############################################
# Explanation: The ALB SG is the blast shield — only allow what the Rebellion needs (80/443).
resource "aws_security_group" "lab_1c_alb_sg01" {
  name        = "${var.project_name}-alb-sg01"
  description = "ALB security group"
  vpc_id      = aws_vpc.lab_1c_vpc01.id
  tags = {
    Name = "${var.project_name}-alb-sg01"
  }
}
# TODO: students add inbound 80/443 from 0.0.0.0/0
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.lab_1c_alb_sg01.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}
resource "aws_vpc_security_group_ingress_rule" "tls" {
  security_group_id = aws_security_group.lab_1c_alb_sg01.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}
# Allow the ALB to send traffic to the EC2 instances on Port 80
resource "aws_vpc_security_group_egress_rule" "alb_to_ec2_traffic" {
  security_group_id            = aws_security_group.lab_1c_alb_sg01.id
  referenced_security_group_id = aws_security_group.lab_1c_ec2_sg01.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

# resource "aws_vpc_security_group_egress_rule" "tg01" {
#   security_group_id = aws_security_group.lab_1c_alb_sg01.id
#   referenced_security_group_id = aws_security_group.lab_1c_ec2_sg01.id
#    from_port   = 80
#   ip_protocol = "tcp"
#   to_port     = 80
# }
############################################
# Application Load Balancer
############################################
# Explanation: The ALB is your public customs checkpoint — it speaks TLS and forwards to private targets.
resource "aws_lb" "lab_1c_alb01" {
  name               = "${var.project_name}-alb01"
  load_balancer_type = "application"
  internal           = false

  security_groups = [aws_security_group.lab_1c_alb_sg01.id]
  subnets         = aws_subnet.lab_1c_public_subnets[*].id

  # TODO: students can enable access logs to S3 as a stretch goal

  tags = {
    Name = "${var.project_name}-alb01"
  }
}
############################################
# Target Group + Attachment
############################################
# Explanation: Target groups are Chewbacca’s “who do I forward to?” list — private EC2 lives here.
resource "aws_lb_target_group" "lab_1c_tg01" {
  name     = "${var.project_name}-tg01"
  port     = 80
  target_type = "instance"
  protocol = "HTTP"
  vpc_id   = aws_vpc.lab_1c_vpc01.id

  # TODO: students set health check path to something real (e.g., /health)
  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    matcher             = "200-399"
  }

  tags = {
    Name = "${var.project_name}-tg01"
  }
}

# Explanation: Chewbacca personally introduces the ALB to the private EC2 — “this is my friend, don’t shoot.”
resource "aws_lb_target_group_attachment" "lab_1c_tg_attach01" {
  target_group_arn = aws_lb_target_group.lab_1c_tg01.arn
  target_id        = aws_instance.lab_1c_ec201.id
  port             = 80

  # TODO: students ensure EC2 security group allows inbound from ALB SG on this port (rule above)
}
############################################
# ALB Listeners: HTTP -> HTTPS redirect, HTTPS -> TG
############################################
# Explanation: HTTP listener is the decoy airlock — it redirects everyone to the secure entrance.
resource "aws_lb_listener" "lab_1c_http_listener01" {
  load_balancer_arn = aws_lb.lab_1c_alb01.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Explanation: HTTPS listener is the real hangar bay — TLS terminates here, then traffic goes to private targets.
resource "aws_lb_listener" "lab_1c_https_listener01" {
  load_balancer_arn = aws_lb.lab_1c_alb01.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.snailtek.arn

###should the certificate be snailtek cert?

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lab_1c_tg01.arn
  }

  depends_on = [aws_acm_certificate_validation.snailtek]
}
###should the certificate be snailtek cert?
############################################
# WAFv2 Web ACL (Basic managed rules)
############################################
# Explanation: WAF is the shield generator — it blocks the cheap blaster fire before it hits your ALB.
resource "aws_wafv2_web_acl" "lab_1c_waf01" {
  count = var.enable_waf ? 1 : 0

  name  = "${var.project_name}-waf01"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-waf01"
    sampled_requests_enabled   = true
  }

  # Explanation: AWS managed rules are like hiring Rebel commandos — they’ve seen every trick.
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-waf-common"
      sampled_requests_enabled   = true
    }
  }

  tags = {
    Name = "${var.project_name}-waf01"
  }
}
# Explanation: Attach the shield generator to the customs checkpoint — ALB is now protected.
resource "aws_wafv2_web_acl_association" "lab_1c_waf_assoc01" {
  count = var.enable_waf ? 1 : 0

  resource_arn = aws_lb.lab_1c_alb01.arn
  web_acl_arn  = aws_wafv2_web_acl.lab_1c_waf01[0].arn
}
############################################
# CloudWatch Alarm: ALB 5xx -> SNS
############################################
# Explanation: When the ALB starts throwing 5xx, that’s the Falcon coughing — page the on-call Wookiee.
resource "aws_cloudwatch_metric_alarm" "lab_1c_alb_5xx_alarm01" {
  alarm_name          = "${var.project_name}-alb-5xx-alarm01"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.alb_5xx_evaluation_periods
  threshold           = var.alb_5xx_threshold
  period              = var.alb_5xx_period_seconds
  statistic           = "Sum"

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_ELB_5XX_Count"

  dimensions = {
    LoadBalancer = aws_lb.lab_1c_alb01.arn_suffix
  }

  alarm_actions = [aws_sns_topic.lab_1c_sns_topic01.arn]

  tags = {
    Name = "${var.project_name}-alb-5xx-alarm01"
  }
}
############################################
# CloudWatch Dashboard (Skeleton)
############################################
# Explanation: Dashboards are your cockpit HUD — Chewbacca wants dials, not vibes.
resource "aws_cloudwatch_dashboard" "lab_1c_dashboard01" {
  dashboard_name = "${var.project_name}-dashboard01"

  # TODO: students can expand widgets; this is a minimal workable skeleton
  dashboard_body = jsonencode({
    widgets = [
      {
        type  = "metric"
        x     = 0
        y     = 0
        width = 12
        height = 6
        properties = {
          metrics = [
            [ "AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.lab_1c_alb01.arn_suffix ],
            [ ".", "HTTPCode_ELB_5XX_Count", ".", aws_lb.lab_1c_alb01.arn_suffix ]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "Lab-1C ALB: Requests + 5XX"
        }
      },
      {
        type  = "metric"
        x     = 12
        y     = 0
        width = 12
        height = 6
        properties = {
          metrics = [
            [ "AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_lb.lab_1c_alb01.arn_suffix ]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "Lab-1c ALB: Target Response Time"
        }
      }
    ]
  })
}