# Sao Paulo Route Table & Routes
resource "aws_route_table" "liberdade_private_rt" {
  vpc_id = aws_vpc.liberdade_vpc01.id

  tags = {
    Name = "liberdade-private-rt"
  }
}


resource "aws_route_table_association" "liberdade_private_assoc" {
  count          = 3
  subnet_id      = element([aws_subnet.liberdade_private_subnet01.id, aws_subnet.liberdade_private_subnet02.id, aws_subnet.liberdade_private_subnet03.id], count.index)
  route_table_id = aws_route_table.liberdade_private_rt.id
}


resource "aws_route" "liberdade_to_shinjuku" {
  route_table_id         = aws_route_table.liberdade_private_rt.id
  destination_cidr_block = "10.249.0.0/20"
  transit_gateway_id     = aws_ec2_transit_gateway.liberdade_tgw01.id
}
