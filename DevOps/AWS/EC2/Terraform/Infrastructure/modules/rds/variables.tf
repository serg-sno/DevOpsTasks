#-------------------------------------------------------------------------------------------------
# Description : RDS DB creation
# Author      : Sergey Sakhno
#-------------------------------------------------------------------------------------------------

variable "application_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "rds_vpc_id" {
  type = string
}

variable "rds_subnet_ids" {
  type = list(string)
}

variable "rds_instance_class" {
  type = string
}

variable "web_servers_cidrs" {
  type = list(string)
}