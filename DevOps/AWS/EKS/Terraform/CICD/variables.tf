#-------------------------------------------------------------------------------------------------
# Description : CICD creation
# Author      : Sergey Sakhno
#-------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "eks_cluster_name" {
  type = string
}

variable "application_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "git_hub_repository_id" {
  type = string
}

variable "git_hub_branch_name" {
  type = string
}

variable "git_hub_connection_arn" {
  type        = string
  description = "Github repository connection ARN"
}