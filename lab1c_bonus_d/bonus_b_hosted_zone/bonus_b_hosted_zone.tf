#########################
# Route53 Hosted Zone   #
#########################

resource "aws_route53_zone" "snailtek" {
  name = "snailtek.click"

  tags = {
    Name        = "snailtek.click"
    Environment = "prod"
  }
}

output "snailtek_name_servers" {
  value = aws_route53_zone.snailtek.name_servers
}
