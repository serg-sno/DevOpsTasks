#-------------------------------------------------------------------------------------------------
# Description : Network layer creation
# Author      : Sergey Sakhno
#-------------------------------------------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# VPCs and subnets
resource "aws_vpc" "ec2_vpc" {
  cidr_block = var.ec2_vpc_cidr

  tags = {
    Name        = "EC2 VPC"
    Application = var.application_name
    Environment = var.environment
  }

}

resource "aws_subnet" "ec2_public" {
  count                   = length(var.ec2_public_subnet_cidrs)
  vpc_id                  = aws_vpc.ec2_vpc.id
  cidr_block              = var.ec2_public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags                    = {
    Name        = "EC2 public ${data.aws_availability_zones.available.names[count.index]}",
    Application = var.application_name
    Environment = var.environment
  }
}

resource "aws_subnet" "ec2_private" {
  count             = length(var.ec2_private_subnet_cidrs)
  vpc_id            = aws_vpc.ec2_vpc.id
  cidr_block        = var.ec2_private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags              = {
    Name                                            = "EC2 private ${data.aws_availability_zones.available.names[count.index]}",
    Application                                     = var.application_name
    Environment = var.environment
  }
}

resource "aws_vpc" "rds_vpc" {
  cidr_block = var.rds_vpc_cidr

  tags = {
    Name        = "RDS VPC"
    Application = var.application_name
    Environment = var.environment
  }
}

resource "aws_subnet" "rds" {
  count             = length(var.rds_subnet_cidrs)
  vpc_id            = aws_vpc.rds_vpc.id
  cidr_block        = var.rds_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags              = {
    Name        = "RDS ${data.aws_availability_zones.available.names[count.index]}",
    Application = var.application_name
    Environment = var.environment
  }
}

#VPC peering, nat, gateways
resource "aws_vpc_peering_connection" "ec2_db" {
  peer_vpc_id = aws_vpc.ec2_vpc.id
  vpc_id      = aws_vpc.rds_vpc.id
  auto_accept = true
  tags        = {
    Name        = "EC2 and RDS VPC peering",
    Application = var.application_name
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ec2_vpc.id

  tags = {
    Name        = "EC2 VPC IGW"
    Application = var.application_name
    Environment = var.environment
  }
}

resource "aws_route_table" "ec2_private" {
  count  = length(var.ec2_private_subnet_cidrs)
  vpc_id = aws_vpc.ec2_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-gateway[count.index].id
  }

  dynamic "route" {
    for_each = var.rds_subnet_cidrs
    content {
      cidr_block                = route.value
      vpc_peering_connection_id = aws_vpc_peering_connection.ec2_db.id
    }
  }
  tags = {
    Name = "Route table for EC2 private subnets"
    Application = var.application_name
    Environment = var.environment
  }
}

resource "aws_route_table_association" "ec2_private" {
  count          = length(var.ec2_private_subnet_cidrs)
  route_table_id = aws_route_table.ec2_private[count.index].id
  subnet_id      = aws_subnet.ec2_private[count.index].id
}

resource "aws_eip" "nat-eip" {
  count      = length(var.ec2_private_subnet_cidrs)
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
  tags       = {
    Name        = "NAT Gateway EIP ${data.aws_availability_zones.available.names[count.index]}"
    Application = var.application_name
  }
}

resource "aws_nat_gateway" "nat-gateway" {
  count         = length(var.ec2_public_subnet_cidrs)
  subnet_id     = aws_subnet.ec2_public[count.index].id
  allocation_id = aws_eip.nat-eip[count.index].id
  tags          = {
    Name        = "NAT Gateway AZ ${data.aws_availability_zones.available.names[count.index]}"
    Application = var.application_name
  }
}

#route tables
resource "aws_route_table" "ec2_public" {
  vpc_id = aws_vpc.ec2_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "Route table for EC2 public subnets"
    Application = var.application_name
    Environment = var.environment
  }
}

resource "aws_route_table_association" "ec2_public" {
  count          = length(var.ec2_public_subnet_cidrs)
  route_table_id = aws_route_table.ec2_public.id
  subnet_id      = aws_subnet.ec2_public[count.index].id
}

resource "aws_route_table" "rds" {
  vpc_id = aws_vpc.rds_vpc.id

  dynamic "route" {
    for_each = var.ec2_private_subnet_cidrs
    content {
      cidr_block                = route.value
      vpc_peering_connection_id = aws_vpc_peering_connection.ec2_db.id
    }
  }
  tags = {
    Name        = "Route table for RDS subnets"
    Application = var.application_name
    Environment = var.environment
  }
}

resource "aws_route_table_association" "rds" {
  count          = length(var.rds_subnet_cidrs)
  route_table_id = aws_route_table.rds.id
  subnet_id      = aws_subnet.rds[count.index].id
}
