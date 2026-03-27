variable "liberdade_tgw_id" {
  type        = string
  description = "The TGW ID from the Sao Paulo (liberdade) deployment"
}

# 1. Create the Tokyo Hub TGW
resource "aws_ec2_transit_gateway" "shinjuku_tgw01" {
  description = "shinjuku-tgw01 (Tokyo hub)"
  tags = { Name = "shinjuku-tgw01" }
}

# 2. Attach the Tokyo VPC to the Hub
resource "aws_ec2_transit_gateway_vpc_attachment" "shinjuku_attach_tokyo_vpc01" {
  transit_gateway_id = aws_ec2_transit_gateway.shinjuku_tgw01.id
  vpc_id             = aws_vpc.shinjuku_vpc01.id
  subnet_ids         = [aws_subnet.shinjuku_private_subnets[0].id, aws_subnet.shinjuku_private_subnets[1].id]
  tags = { Name = "shinjuku-attach-tokyo-vpc01" }
}

# # 3. The Fresh Peering Request (UNCOMMENT THIS)
resource "aws_ec2_transit_gateway_peering_attachment" "shinjuku_to_liberdade_peer01" {
  transit_gateway_id      = aws_ec2_transit_gateway.shinjuku_tgw01.id
  peer_region             = "sa-east-1"
  peer_transit_gateway_id = var.liberdade_tgw_id # Uses the value from your .tfvars 

  tags = { Name = "shinjuku-to-liberdade-peer01" }
}

# 4. Internal TGW Route (This uses the peering ID above)
resource "aws_ec2_transit_gateway_route" "tokyo_to_sp_tgw_route" {
  destination_cidr_block         = "10.249.16.0/21" # Sao Paulo's VPC range
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.shinjuku_to_liberdade_peer01.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.shinjuku_tgw01.association_default_route_table_id
}