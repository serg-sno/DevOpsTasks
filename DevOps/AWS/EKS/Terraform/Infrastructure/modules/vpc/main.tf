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
resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.eks_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "EKS worker nodes VPC"
    Application = var.application_name
  }

}

resource "aws_subnet" "eks_public" {
  count                   = length(var.eks_public_subnet_cidrs)
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.eks_public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags                    = {
    Name                                            = "EKS public ${data.aws_availability_zones.available.names[count.index]}",
    Application                                     = var.application_name
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared",
    "kubernetes.io/role/elb"                        = 1,
  }
}

resource "aws_subnet" "eks_private" {
  count             = length(var.eks_private_subnet_cidrs)
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = var.eks_private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags              = {
    Name                                            = "EKS private ${data.aws_availability_zones.available.names[count.index]}",
    Application                                     = var.application_name
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared",
    "kubernetes.io/role/internal-elb"               = 1,
  }
}

resource "aws_vpc" "rds_vpc" {
  cidr_block = var.rds_vpc_cidr

  tags = {
    Name        = "RDS VPC"
    Application = var.application_name
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
  }
}

#VPC peering, nat, gateways
resource "aws_vpc_peering_connection" "eks_db" {
  peer_vpc_id = aws_vpc.eks_vpc.id
  vpc_id      = aws_vpc.rds_vpc.id
  auto_accept = true
  tags              = {
    Name        = "EKS and RDS VPC peering",
    Application = var.application_name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "EKS VPC IGW"
    Application = var.application_name
  }
}

resource "aws_eip" "nat-eip" {
  count      = length(var.eks_private_subnet_cidrs)
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "NAT Gateway EIP ${data.aws_availability_zones.available.names[count.index]}"
    Application = var.application_name
  }
}

resource "aws_nat_gateway" "nat-gateway" {
  count         = length(var.eks_public_subnet_cidrs)
  subnet_id     = aws_subnet.eks_public[count.index].id
  allocation_id = aws_eip.nat-eip[count.index].id
  tags = {
    Name = "NAT Gateway AZ ${data.aws_availability_zones.available.names[count.index]}"
    Application = var.application_name
  }
}

#route tables
resource "aws_route_table" "eks_public" {
  vpc_id = aws_vpc.eks_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Route table for EKS public subnets"
    Application = var.application_name
  }
}

resource "aws_route_table_association" "eks_public" {
  count          = length(var.eks_public_subnet_cidrs)
  route_table_id = aws_route_table.eks_public.id
  subnet_id      = aws_subnet.eks_public[count.index].id
}

resource "aws_route_table" "eks_private" {
  count  = length(var.eks_private_subnet_cidrs)
  vpc_id = aws_vpc.eks_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-gateway[count.index].id
  }

  dynamic "route" {
    for_each = var.rds_subnet_cidrs
    content {
      cidr_block                = route.value
      vpc_peering_connection_id = aws_vpc_peering_connection.eks_db.id
    }
  }
  tags = {
    Name = "Route table for EKS private subnet AZ ${data.aws_availability_zones.available.names[count.index]}"
    Application = var.application_name
  }
}

resource "aws_route_table_association" "eks_private" {
  count          = length(var.eks_private_subnet_cidrs)
  route_table_id = aws_route_table.eks_private[count.index].id
  subnet_id      = aws_subnet.eks_private[count.index].id
}

resource "aws_route_table" "rds" {
  vpc_id = aws_vpc.rds_vpc.id

  dynamic "route" {
    for_each = var.eks_private_subnet_cidrs
    content {
      cidr_block                = route.value
      vpc_peering_connection_id = aws_vpc_peering_connection.eks_db.id
    }
  }
  tags = {
    Name = "Route table for RDS subnets"
    Application = var.application_name
  }
}

resource "aws_route_table_association" "rds" {
  count          = length(var.rds_subnet_cidrs)
  route_table_id = aws_route_table.rds.id
  subnet_id      = aws_subnet.rds[count.index].id
}
