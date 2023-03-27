#-------------------------------------------------------------------------------------------------
# Description : Infrastructure creation (VPC, subnets, IGW, NAT Gateways, EC2 instances, RDS, ...)
# Author      : Sergey Sakhno
#-------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "application_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "ec2_vpc_cidr" {
  type = string
}

variable "ec2_public_subnet_cidrs" {
  type = list(string)
}

variable "ec2_private_subnet_cidrs" {
  type = list(string)
}

variable "ec2_instance_type" {
  type = string
}

variable "rds_vpc_cidr" {
  type = string
}

variable "rds_subnet_cidrs" {
  type = list(string)
}

variable "rds_instance_class" {
  type = string
}

