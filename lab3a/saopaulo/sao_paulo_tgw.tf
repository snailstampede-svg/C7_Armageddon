# 1. The Sao Paulo Transit Gateway
resource "aws_ec2_transit_gateway" "liberdade_tgw01" {
  description = "liberdade-tgw01 (Sao Paulo spoke)"
  tags        = { Name = "liberdade-tgw01" }
}

# 2. The Accepter - This MUST use the new ID ending in '9fafd'
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "liberdade_accept_peer01" {
  # Ensure NO provider line is here
  transit_gateway_attachment_id = "tgw-attach-04d7c5720c229fafd"

  tags = { Name = "liberdade-accept-peer01" }
}

# 3. VPC Attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "liberdade_attach_sp_vpc01" {
  transit_gateway_id = aws_ec2_transit_gateway.liberdade_tgw01.id
  vpc_id             = aws_vpc.liberdade_vpc01.id
  subnet_ids         = [aws_subnet.liberdade_private_subnet01.id, aws_subnet.liberdade_private_subnet02.id, aws_subnet.liberdade_private_subnet03.id]
  tags               = { Name = "liberdade-attach-sp-vpc01" }
}

# 4. Internal TGW Route - Keep this COMMENTED OUT for the first run
resource "aws_ec2_transit_gateway_route" "sp_to_tokyo_tgw_route" {
  destination_cidr_block         = "10.249.0.0/20" 
  transit_gateway_attachment_id  = "tgw-attach-04d7c5720c229fafd" # UPDATED ID
  transit_gateway_route_table_id = aws_ec2_transit_gateway.liberdade_tgw01.association_default_route_table_id
}