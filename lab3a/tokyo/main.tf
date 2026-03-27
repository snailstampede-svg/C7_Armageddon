############################################
# Locals (naming convention: Chewbacca-*)
############################################
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  name_prefix         = var.project_name
  secret_arn_wildcard = "arn:aws:secretsmanager:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:secret:${local.name_prefix}/rds/mysql*"
}

############################################
# VPC + Internet Gateway
############################################

# Explanation: Chewbacca needs a hyperlane—this VPC is the Millennium Falcon’s flight corridor.
resource "aws_vpc" "shinjuku_vpc01" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.name_prefix}-vpc01"
  }
}

# Explanation: Even Wookiees need to reach the wider galaxy—IGW is your door to the public internet.
resource "aws_internet_gateway" "shinjuku_igw01" {
  vpc_id = aws_vpc.shinjuku_vpc01.id

  tags = {
    Name = "${local.name_prefix}-igw01"
  }
}

############################################
# Subnets (Public + Private)
############################################

# Explanation: Public subnets are like docking bays—ships can land directly from space (internet).
resource "aws_subnet" "shinjuku_public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.shinjuku_vpc01.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name_prefix}-public-subnet0${count.index + 1}"
  }
}

# Explanation: Private subnets are the hidden Rebel base—no direct access from the internet.
resource "aws_subnet" "shinjuku_private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.shinjuku_vpc01.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "${local.name_prefix}-private-subnet0${count.index + 1}"
  }
}
############################################
# Routing (Public + Private Route Tables)
############################################
# Explanation: Public route table = “open lanes” to the galaxy via IGW.
resource "aws_route_table" "shinjuku_public_rt01" {
  vpc_id = aws_vpc.shinjuku_vpc01.id

  tags = {
    Name = "${local.name_prefix}-public-rt01"
  }
}

# Explanation: This route is the Kessel Run—0.0.0.0/0 goes out the IGW.
resource "aws_route" "shinjuku_public_default_route" {
  route_table_id         = aws_route_table.shinjuku_public_rt01.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.shinjuku_igw01.id
}

# Explanation: Attach public subnets to the “public lanes.”
resource "aws_route_table_association" "shinjuku_public_rta" {
  count          = length(aws_subnet.shinjuku_public_subnets)
  subnet_id      = aws_subnet.shinjuku_public_subnets[count.index].id
  route_table_id = aws_route_table.shinjuku_public_rt01.id
}

# Explanation: Private route table = “stay hidden, but still ship supplies.”
resource "aws_route_table" "shinjuku_private_rt01" {
  vpc_id = aws_vpc.shinjuku_vpc01.id

  tags = {
    Name = "${local.name_prefix}-private-rt01"
  }
}

# Explanation: Attach private subnets to the “stealth lanes.”
resource "aws_route_table_association" "shinjuku_private_rta" {
  count          = length(aws_subnet.shinjuku_private_subnets)
  subnet_id      = aws_subnet.shinjuku_private_subnets[count.index].id
  route_table_id = aws_route_table.shinjuku_private_rt01.id
}

############################################
# Security Groups (EC2 + RDS)
############################################

# Explanation: EC2 SG is Chewbacca’s bodyguard—only let in what you mean to.
resource "aws_security_group" "shinjuku_ec2_sg01" {
  name        = "${local.name_prefix}-ec2-sg01"
  description = "EC2 app security group"
  vpc_id      = aws_vpc.shinjuku_vpc01.id
  tags = {
    Name = "${local.name_prefix}-ec2-sg01"
  }

  #TODO: student adds inbound rules (HTTP 80, SSH 22 from their IP)
  #Allow HTTP into the ec2 app
  ingress {
    description     = "Allow HTTP to EC2 Instance"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.shinjuku_alb_sg01.id]

  }
  #Outbound rule to allow responses from the EC2 to the outside world

  egress {
    description = "All all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "shinjuku_vpce_sg01" {
  name        = "${local.name_prefix}-vpce-sg01"
  description = "Security Group for VPC Endpoints"
  vpc_id      = aws_vpc.shinjuku_vpc01.id

  ingress {
    description     = "Allow HTTPS from EC2 SG"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.shinjuku_ec2_sg01.id]
  }
}
# TODO: student ensures outbound allows DB port to RDS SG (or allow all outbound)
# Explanation: RDS SG is the Rebel vault—only the app server gets a keycard.
resource "aws_security_group" "shinjuku_rds_sg01" {
  name        = "${local.name_prefix}-rds-sg01"
  description = "RDS security group"
  vpc_id      = aws_vpc.shinjuku_vpc01.id

  # TODO: student adds inbound MySQL 3306 from aws_security_group.chewbacca_ec2_sg01.id

  tags = {
    Name = "${local.name_prefix}-rds-sg01"
  }
  # rule to allow incoming requests from  EC2 ONLY i.e. no requests allowed from anything other than the ec2 security group
  ingress {

    description     = "Allow MySQL from EC2 only"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.shinjuku_ec2_sg01.id]
  }

    egress {
    description = "Outbound responses from RDS"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_liberdade_to_shinjuku_rds" {
  # This must match the resource name from your previous lab
  security_group_id = aws_security_group.shinjuku_rds_sg01.id 
  
  description = "Allow MySQL 3306 from Sao Paulo (Liberdade) VPC CIDR"
  from_port   = 3306
  to_port     = 3306
  ip_protocol = "tcp"
  
  # The "Engineering Truth": Security Group IDs don't work over TGW Peering.
  # We MUST use the specific CIDR of the Liberdade VPC.
  cidr_ipv4   = "10.249.16.0/21" 

  tags = {
    Name = "allow-liberdade-to-shinjuku-rds"
  }
}

#############################################
# VPC Endpoints (Private Connectivity)      #
#############################################
resource "aws_vpc_endpoint" "s3_gw" {
  vpc_id            = aws_vpc.shinjuku_vpc01.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.shinjuku_private_rt01.id]
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.shinjuku_vpc01.id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.shinjuku_private_subnets[*].id
  security_group_ids  = [aws_security_group.shinjuku_vpce_sg01.id]
}
# Explanation: ec2messages is the Wookiee messenger—SSM sessions won’t work without it.
resource "aws_vpc_endpoint" "shinjuku_vpce_ec2messages01" {
  vpc_id              = aws_vpc.shinjuku_vpc01.id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = aws_subnet.shinjuku_private_subnets[*].id
  security_group_ids = [aws_security_group.shinjuku_vpce_sg01.id]

  tags = {
    Name = "${local.name_prefix}-vpce-ec2messages01"
  }
}

# Explanation: ssmmessages is the holonet channel—Session Manager needs it to talk back.
resource "aws_vpc_endpoint" "shinjuku_vpce_ssmmessages01" {
  vpc_id              = aws_vpc.shinjuku_vpc01.id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = aws_subnet.shinjuku_private_subnets[*].id
  security_group_ids = [aws_security_group.shinjuku_vpce_sg01.id]

  tags = {
    Name = "${local.name_prefix}-vpce-ssmmessages01"
  }
}
############################################
# VPC Endpoint - Secrets Manager (Interface)
############################################
resource "aws_vpc_endpoint" "secrets" {
  vpc_id              = aws_vpc.shinjuku_vpc01.id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.shinjuku_private_subnets[*].id
  security_group_ids  = [aws_security_group.shinjuku_vpce_sg01.id]
  tags = {
    Name = "${local.name_prefix}-vpce-secrets01"
  }
}
############################################
# VPC Endpoint - CloudWatch Logs (Interface)
############################################
# Explanation: CloudWatch Logs is the ship’s black box—Chewbacca wants crash data, always.

resource "aws_vpc_endpoint" "shinjuku_vpce_logs01" {
  vpc_id              = aws_vpc.shinjuku_vpc01.id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = aws_subnet.shinjuku_private_subnets[*].id
  security_group_ids = [aws_security_group.shinjuku_vpce_sg01.id]

  tags = {
    Name = "${local.name_prefix}-vpce-logs01"
  }
}
############################################
# RDS Subnet Group
############################################

# Explanation: RDS hides in private subnets like the Rebel base on Hoth—cold, quiet, and not public.
resource "aws_db_subnet_group" "shinjuku_rds_subnet_group01" {
  name       = "${local.name_prefix}-rds-subnet-group01"
  subnet_ids = aws_subnet.shinjuku_private_subnets[*].id

  tags = {
    Name = "${local.name_prefix}-rds-subnet-group01"
  }
}
############################################
# RDS Instance (MySQL)
############################################

# Explanation: This is the holocron of state—your relational data lives here, not on the EC2.
resource "aws_db_instance" "lab1crds" {
  identifier        = "${local.name_prefix}-rds01"
  engine            = var.db_engine
  instance_class    = var.db_instance_class
  allocated_storage = 20
  db_name           = var.db_name
  username          = var.db_username
  password          = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.shinjuku_rds_subnet_group01.name
  vpc_security_group_ids = [aws_security_group.shinjuku_rds_sg01.id]

  publicly_accessible = false
  skip_final_snapshot = true

  # TODO: student sets multi_az / backups / monitoring as stretch goals

  tags = {
    Name = "${local.name_prefix}-rds01"
  }
}
############################################
# IAM Role + Instance Profile for EC2
############################################
# Explanation: Chewbacca refuses to carry static keys—this role lets EC2 assume permissions safely.
resource "aws_iam_role" "shinjuku_ec2_role01" {
  name = "${local.name_prefix}-ec2-role01"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}
############################################
# Least-Privilege IAM (BONUS A)
############################################

# Explanation: Chewbacca doesn’t hand out the Falcon keys—this policy scopes reads to your lab paths only.
resource "aws_iam_policy" "shinjuku_leastpriv_read_params01" {
  name        = "${local.name_prefix}-lp-ssm-read01"
  description = "Least-privilege read for SSM Parameter Store under /lab/db/*"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadLabDbParams"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = [
          "arn:aws:ssm:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:parameter/lab/db/*"
        ]
      }
    ]
  })
}

# Explanation: Chewbacca only opens *this* vault—GetSecretValue for only your secret (not the whole planet).
resource "aws_iam_policy" "shinjuku_leastpriv_read_secret01" {
  name        = "${local.name_prefix}-lp-secrets-read01"
  description = "Least-privilege read for the lab DB secret"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadOnlyLabSecret"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = local.secret_arn_wildcard
      }
    ]
  })
}

# Explanation: When the Falcon logs scream, this lets Chewbacca ship logs to CloudWatch without giving away the Death Star plans.
resource "aws_iam_policy" "shinjuku_leastpriv_cwlogs01" {
  name        = "${local.name_prefix}-lp-cwlogs01"
  description = "Least-privilege CloudWatch Logs write for the app log group"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "WriteLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          "${aws_cloudwatch_log_group.shinjuku_log_group01.arn}:*"
        ]
      }
    ]
  })
}

# Explanation: These policies are your Wookiee toolbelt—tighten them (least privilege) as a stretch goal.
resource "aws_iam_role_policy_attachment" "shinjuku_ec2_ssm_attach" {
  role       = aws_iam_role.shinjuku_ec2_role01.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Explanation: EC2 must read secrets/params during recovery—give it access (students should scope it down).
resource "aws_iam_role_policy_attachment" "shinjuku_ec2_secrets_attach" {
  role       = aws_iam_role.shinjuku_ec2_role01.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite" # TODO: student replaces w/ least privilege
}

# Explanation: CloudWatch logs are the “ship’s black box”—you need them when things explode.
resource "aws_iam_role_policy_attachment" "shinjuku_ec2_cw_attach" {
  role       = aws_iam_role.shinjuku_ec2_role01.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Explanation: Instance profile is the harness that straps the role onto the EC2 like bandolier ammo.
resource "aws_iam_instance_profile" "shinjuku_instance_profile01" {
  name = "${local.name_prefix}-instance-profile01"
  role = aws_iam_role.shinjuku_ec2_role01.name
}

resource "aws_instance" "shinjuku_ec201" {
  ami                    = var.ec2_ami_id
  instance_type          = var.ec2_instance_type
  subnet_id              = aws_subnet.shinjuku_private_subnets[0].id # MOVED TO PRIVATE 
  vpc_security_group_ids = [aws_security_group.shinjuku_ec2_sg01.id]
  iam_instance_profile   = aws_iam_instance_profile.shinjuku_instance_profile01.name

  user_data = templatefile("${path.module}/user_data-1.sh", {
    region         = var.aws_region
    secret_id      = aws_secretsmanager_secret.shinjuku_db_secret01.name
    log_group_name = aws_cloudwatch_log_group.shinjuku_log_group01.name
  })

  tags = { Name = "${local.name_prefix}-ec201-hardened" }
}

############################################
# Parameter Store (SSM Parameters)
############################################

# Explanation: Parameter Store is Chewbacca’s map—endpoints and config live here for fast recovery.
resource "aws_ssm_parameter" "shinjuku_db_endpoint_param" {
  name  = "/lab/db/endpoint"
  type  = "String"
  value = aws_db_instance.lab1crds.address

  tags = {
    Name = "${local.name_prefix}-param-db-endpoint"
  }
}

# Explanation: Ports are boring, but even Wookiees need to know which door number to kick in.
resource "aws_ssm_parameter" "shinjuku_db_port_param" {
  name  = "/lab/db/port"
  type  = "String"
  value = tostring(aws_db_instance.lab1crds.port)

  tags = {
    Name = "${local.name_prefix}-param-db-port"
  }
}

# Explanation: DB name is the label on the crate—without it, you’re rummaging in the dark.
resource "aws_ssm_parameter" "shinjuku_db_name_param" {
  name  = "/lab/db/name"
  type  = "String"
  value = var.db_name

  tags = {
    Name = "${local.name_prefix}-param-db-name"
  }
}

############################################
# Secrets Manager (DB Credentials)
############################################

# Explanation: Secrets Manager is Chewbacca’s locked holster—credentials go here, not in code.
resource "aws_secretsmanager_secret" "shinjuku_db_secret01" {
  name = "${local.name_prefix}/rds/mysql_v1"
}

# Explanation: Secret payload—students should align this structure with their app (and support rotation later).
resource "aws_secretsmanager_secret_version" "shinjuku_db_secret_version01" {
  secret_id = aws_secretsmanager_secret.shinjuku_db_secret01.id

  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    host     = aws_db_instance.lab1crds.address
    port     = aws_db_instance.lab1crds.port
    dbname   = var.db_name
  })
}

############################################
# CloudWatch Logs (Log Group)
############################################

# Explanation: When the Falcon is on fire, logs tell you *which* wire sparked—ship them centrally.
resource "aws_cloudwatch_log_group" "shinjuku_log_group01" {
  name              = "/aws/ec2/${local.name_prefix}-rds-app"
  retention_in_days = 7

  tags = {
    Name = "${local.name_prefix}-log-group01"
  }
}

############################################
# Custom Metric + Alarm (Skeleton)
############################################

# Explanation: Metrics are Chewbacca’s growls—when they spike, something is wrong.
# NOTE: Students must emit the metric from app/agent; this just declares the alarm.
resource "aws_cloudwatch_metric_alarm" "shinjuku_db_alarm01" {
  alarm_name          = "${local.name_prefix}-db-connection-failure"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "DBConnectionErrors"
  namespace           = "Lab/RDSApp"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.shinjuku_sns_topic01.arn]

  tags = {
    Name = "${local.name_prefix}-alarm-db-fail"
  }
}

### CloudWatch Metric Filter

# This filter scans the logs for the specific MySQL error pattern
resource "aws_cloudwatch_log_metric_filter" "shinjuku_db_error_filter" {
  name           = "${local.name_prefix}-db-error-filter"
  pattern        = "Error" # The exact string from your journalctl logs
  log_group_name = aws_cloudwatch_log_group.shinjuku_log_group01.name

  metric_transformation {
    name      = "DBConnectionErrors" # Must match your Alarm's metric_name
    namespace = "Lab/RDSApp"         # Must match your Alarm's namespace
    value     = "1"                  # Increment by 1 for every match
  }
}
############################################
# SNS (PagerDuty simulation)
############################################

# Explanation: SNS is the distress beacon—when the DB dies, the galaxy (your inbox) must hear about it.
resource "aws_sns_topic" "shinjuku_sns_topic01" {
  name = "${local.name_prefix}-db-incidents"
}

# Explanation: Email subscription = “poor man’s PagerDuty”—still enough to wake you up at 3AM.
resource "aws_sns_topic_subscription" "shinjuku_sns_sub01" {
  topic_arn = aws_sns_topic.shinjuku_sns_topic01.arn
  protocol  = "email"
  endpoint  = var.sns_email_endpoint
}

############################################
# (Optional but realistic) VPC Endpoints (Skeleton)
############################################

# Explanation: Endpoints keep traffic inside AWS like hyperspace lanes—less exposure, more control.
# TODO: students can add endpoints for SSM, Logs, Secrets Manager if doing “no public egress” variant.
# resource "aws_vpc_endpoint" "chewbacca_vpce_ssm" { ... }