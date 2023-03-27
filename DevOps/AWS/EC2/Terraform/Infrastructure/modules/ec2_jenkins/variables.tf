#-------------------------------------------------------------------------------------------------
# Description : EC2 jenkins server
# Author      : Sergey Sakhno
#-------------------------------------------------------------------------------------------------

variable "application_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "ec2_jenkins_subnet_ids" {
  type = list(string)
}

variable "ec2_jenkins_instance_type" {
  type = string
  default = "t3.small"
}

variable "ec2_jenkins_vpc_id" {
  type = string
}