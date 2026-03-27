resource "aws_security_group" "liberdade_ec2_sg" {
  name        = "liberdade-ec2-sg"
  description = "Restricted outbound to Tokyo and SSM only"
  vpc_id      = aws_vpc.liberdade_vpc01.id

  # 1. Allow the app to talk to the Tokyo RDS vault
  egress {
    description = "Authoritative storage access in Shinjuku"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.249.0.0/20"] # Tokyo VPC CIDR
  }

 
  egress {
    description = "Allow SSM for management"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
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
resource "aws_instance" "liberdade_ec201" {
  ami                         = "ami-0af6e9042ea5a4e3e"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.liberdade_private_subnet01.id
  associate_public_ip_address = true

  iam_instance_profile   = aws_iam_instance_profile.liberdade_instance_profile.name
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
