#-------------------------------------------------------------------------------------------------
# Description : AWS Loadbalancer controller for EKS installation
# Author      : Sergey Sakhno
#-------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "application_name" {
  type = string
}

variable "eks_cluster_name" {
  type = string
}
