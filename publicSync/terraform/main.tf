provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "rescue_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "rescueVPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "rescue_igw" {
  vpc_id = aws_vpc.rescue_vpc.id
  tags = {
    Name = "rescueInternetGateway"
  }
}

# Route Table
resource "aws_route_table" "rescue_route_table" {
  vpc_id = aws_vpc.rescue_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.rescue_igw.id
  }

  tags = {
    Name = "rescueRouteTable"
  }
}

# Route Table Association for Subnet AZ 1
resource "aws_route_table_association" "rescue_route_table_assoc_az1" {
  subnet_id      = aws_subnet.rescue_subnet_az1.id
  route_table_id = aws_route_table.rescue_route_table.id
}

# Route Table Association for Subnet AZ 2
resource "aws_route_table_association" "rescue_route_table_assoc_az2" {
  subnet_id      = aws_subnet.rescue_subnet_az2.id
  route_table_id = aws_route_table.rescue_route_table.id
}

# Subnet in AZ 1
resource "aws_subnet" "rescue_subnet_az1" {
  vpc_id                  = aws_vpc.rescue_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "rescueSubnetAZ1"
  }
}

# Subnet in AZ 2
resource "aws_subnet" "rescue_subnet_az2" {
  vpc_id                  = aws_vpc.rescue_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "rescueSubnetAZ2"
  }
}

# RDS Subnet Group (requires at least two subnets in different AZs)
resource "aws_db_subnet_group" "rescue_subnet_group" {
  name       = "rescue-db-subnet-group"
  subnet_ids = [aws_subnet.rescue_subnet_az1.id, aws_subnet.rescue_subnet_az2.id]
  tags = {
    Name = "rescueSubnetGroup"
  }
}

# RDS PostgreSQL Database
resource "aws_db_instance" "rescue_postgresql" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "16.3"
  instance_class       = "db.t3.micro"  # Free-tier eligible
  username             = "upasana1"
  password             = var.db_password  # Use environment variable for password
  skip_final_snapshot  = true
  publicly_accessible  = true
  db_subnet_group_name = aws_db_subnet_group.rescue_subnet_group.name
  tags = {
    Name = "rescuePostgreSQL"
  }
}

# EC2 Instance
resource "aws_instance" "rescue_ec2" {
  ami           = "ami-01e3c4a339a264cc9"  # Provided valid Amazon Linux 2 AMI ID
  instance_type = "t2.micro"               # Free tier instance type
  subnet_id     = aws_subnet.rescue_subnet_az1.id

  tags = {
    Name = "rescueEC2Instance"
  }

  # User data to set up EC2 instance (e.g., install PostgreSQL client)
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y postgresql
              EOF
}

# Outputs
output "ec2_public_ip" {
  value = aws_instance.rescue_ec2.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.rescue_postgresql.endpoint
}

# Variable for DB password
variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}
