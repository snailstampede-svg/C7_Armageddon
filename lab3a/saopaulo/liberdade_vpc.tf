# The Foundation: Sao Paulo VPC
resource "aws_vpc" "liberdade_vpc01" {
  cidr_block           = "10.249.16.0/21" # The Sao Paulo Range
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "liberdade-vpc01" }
}

# Public Subnet 01 (For the ALB)
resource "aws_subnet" "liberdade_public_subnet01" {
  vpc_id                  = aws_vpc.liberdade_vpc01.id
  cidr_block              = "10.249.16.0/24"
  availability_zone       = "sa-east-1a"
  map_public_ip_on_launch = true
  tags                    = { Name = "liberdade-public-subnet01" }
}

# Public Subnet 02 (For the ALB)
resource "aws_subnet" "liberdade_public_subnet02" {
  vpc_id                  = aws_vpc.liberdade_vpc01.id
  cidr_block              = "10.249.17.0/24"
  availability_zone       = "sa-east-1b"
  map_public_ip_on_launch = true
  tags                    = { Name = "liberdade-public-subnet02" }
}

###########################################
# Sao Paulo - Private Subnets for TGW
###########################################

# Private Subnet 01 (You likely already have this)
resource "aws_subnet" "liberdade_private_subnet01" {
  vpc_id            = aws_vpc.liberdade_vpc01.id
  cidr_block        = "10.249.18.0/24"
  availability_zone = "sa-east-1a"
  tags              = { Name = "liberdade-private-subnet01" }
}

# Private Subnet 02 (The missing resource)
resource "aws_subnet" "liberdade_private_subnet02" {
  vpc_id            = aws_vpc.liberdade_vpc01.id
  cidr_block        = "10.249.19.0/24"
  availability_zone = "sa-east-1b"
  tags              = { Name = "liberdade-private-subnet02" }
}

# Private Subnet 03 (The other missing resource)
resource "aws_subnet" "liberdade_private_subnet03" {
  vpc_id            = aws_vpc.liberdade_vpc01.id
  cidr_block        = "10.249.20.0/24"
  availability_zone = "sa-east-1c"
  tags              = { Name = "liberdade-private-subnet03" }
}