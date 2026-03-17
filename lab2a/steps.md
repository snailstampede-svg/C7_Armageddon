### Step 0 ###

1. create acm cert in N. Virginia

    # Add new cert in  N. Virginia Cloudfront. Also create alias virginia 
resource "aws_acm_certificate" "cert" {
  provider          = aws.virginia
  domain_name       = "snailtek.click"
  subject_alternative_names = ["*.snailtek.click"]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

2. declared variable for acm N. Virginia certificate
    variable "cloudfront_acm_cert_arn" {
  description = "ACM certificate ARN in us-east-1 for CloudFront (covers snailtek.click and app.snailtek.click)."
  type        = string
  default = aws_acm_certificate.NV-cert.arn
}

3. ACM cert referenced for cloudfront use
      # TODO: students must use ACM cert in us-east-1 for CloudFront
  viewer_certificate {
    acm_certificate_arn      = var.cloudfront_acm_cert_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

### Step 1 ###

1. Allow ALB inbound only from CF prefix list
2. Add ingress rule to ALB 

    resource "aws_security_group_ingress_rule" "lab_1c_alb_ingress_cf44301" {
  security_group_id = aws_security_group.lab_1c_alb_sg01.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  prefix_list_ids = [
    data.aws_ec2_managed_prefix_list.lab_1c_cf_origin_facing01.id
  ]
}

### Step 2 ###

1. Add the secret origin header for CF to include in its traffic. 
2. On the ALB listener. Add a rule to check for this header. If header matches, then ALB will forward traffic.


### Step 3 ###
