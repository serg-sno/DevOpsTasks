#-------------------------------------------------------------------------------------------------
# Description : Web servers
# Author      : Sergey Sakhno
#-------------------------------------------------------------------------------------------------

variable "application_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "web_servers_instance_type" {
  type = string
  default = "t3.micro"
}

variable "web_servers_vpc_id" {
  type = string
}

variable "web_servers_subnets_ids" {
  type = list(string)
}

variable "public_subnets_cidr_blocks" {
  type = list(string)
}