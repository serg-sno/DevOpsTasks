#-------------------------------------------------------------------------------------------------
# Description : Infrastructure creation (VPC, subnets, IGW, NAT Gateways, EKS Cluster, ...)
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

variable "eks_vpc_cidr" {
  type = string
}

variable "eks_public_subnet_cidrs" {
  type = list(string)
}

variable "eks_private_subnet_cidrs" {
  type = list(string)
}

variable "eks_cluster_name" {
  type = string
}

variable "eks_cluster_instance_type" {
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

