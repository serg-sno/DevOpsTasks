#-------------------------------------------------------------------------------------------------
# Description : Network layer creation
# Author      : Sergey Sakhno
#-------------------------------------------------------------------------------------------------

variable "application_name" {
  type = string
}

variable "eks_vpc_cidr" {
  type = string
}

variable "eks_public_subnet_cidrs" {
  type    = list(string)
}

variable "eks_private_subnet_cidrs" {
  type    = list(string)
}

variable "eks_cluster_name" {
  type = string
}

variable "rds_vpc_cidr" {
  type = string
}

variable "rds_subnet_cidrs" {
  type    = list(string)
}
