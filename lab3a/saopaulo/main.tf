# Sao Paulo VPC and Subnets
resource "aws_vpc" "liberdade_vpc01" {
  cidr_block           = "10.249.16.0/21"
  enable_dns_hostnames = true
  tags                 = { Name = "liberdade-vpc01" }
}

resource "aws_subnet" "liberdade_private_subnet01" {
  vpc_id            = aws_vpc.liberdade_vpc01.id
  cidr_block        = "10.249.16.0/24"
  availability_zone = "sa-east-1a"
  tags              = { Name = "liberdade-private-subnet01" }
}

resource "aws_subnet" "liberdade_private_subnet02" {
  vpc_id            = aws_vpc.liberdade_vpc01.id
  cidr_block        = "10.249.17.0/24"
  availability_zone = "sa-east-1b"
  tags              = { Name = "liberdade-private-subnet02" }
}

resource "aws_subnet" "liberdade_private_subnet03" {
  vpc_id            = aws_vpc.liberdade_vpc01.id
  cidr_block        = "10.249.18.0/24"
  availability_zone = "sa-east-1c"
  tags              = { Name = "liberdade-private-subnet03" }
}

resource "aws_security_group" "liberdade_ec2_sg" {
  name        = "liberdade-ec2-sg"
  description = "Allow SSM and outbound to Tokyo"
  vpc_id      = aws_vpc.liberdade_vpc01.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM Role
resource "aws_iam_role" "liberdade_ssm_role" {
  name = "liberdade-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.liberdade_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "liberdade_instance_profile" {
  name = "liberdade-instance-profile"
  role = aws_iam_role.liberdade_ssm_role.name
}

# Sao Paulo EC2 Instance
resource "aws_instance" "liberdade_test_node" {
  ami           = "ami-0af6e9042ea5a4e3e" 
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.liberdade_private_subnet01.id
  associate_public_ip_address = true
  
  iam_instance_profile = aws_iam_instance_profile.liberdade_instance_profile.name 
  vpc_security_group_ids = [aws_security_group.liberdade_ec2_sg.id]
  tags = {
    Name = "liberdade-test-node"
  }
}

resource "aws_internet_gateway" "liberdade_igw" {
  vpc_id = aws_vpc.liberdade_vpc01.id
  tags   = { Name = "liberdade-igw" }
}

resource "aws_route" "liberdade_internet_access" {
  route_table_id         = aws_route_table.liberdade_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.liberdade_igw.id
}
