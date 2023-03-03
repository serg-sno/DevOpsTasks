#-------------------------------------------------------------------------------------------------
# Description : CICD creation
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

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

module "cicd" {
  source                 = "./modules/CICD"
  aws_region             = var.aws_region
  application_name       = var.application_name
  environment            = var.environment
  eks_cluster_name       = var.eks_cluster_name
  git_hub_repository_id  = var.git_hub_repository_id
  git_hub_branch_name    = var.git_hub_branch_name
  git_hub_connection_arn = var.git_hub_connection_arn
}
