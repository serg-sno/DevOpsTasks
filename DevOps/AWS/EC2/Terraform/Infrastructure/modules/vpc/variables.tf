#-------------------------------------------------------------------------------------------------
# Description : Network layer creation
# Author      : Sergey Sakhno
#-------------------------------------------------------------------------------------------------

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
  type    = list(string)
}

variable "ec2_private_subnet_cidrs" {
  type    = list(string)
}

variable "rds_vpc_cidr" {
  type = string
}

variable "rds_subnet_cidrs" {
  type    = list(string)
}
