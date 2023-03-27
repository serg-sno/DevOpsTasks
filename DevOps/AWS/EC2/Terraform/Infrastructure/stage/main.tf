#-------------------------------------------------------------------------------------------------
# Description : Infrastructure creation (VPC, subnets, IGW, NAT Gateways, EC2 instances, RDS, ...)
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

module "vpc" {
  source                   = "../modules/vpc"
  ec2_vpc_cidr             = var.ec2_vpc_cidr
  ec2_public_subnet_cidrs  = var.ec2_public_subnet_cidrs
  ec2_private_subnet_cidrs = var.ec2_private_subnet_cidrs
  rds_vpc_cidr             = var.rds_vpc_cidr
  rds_subnet_cidrs         = var.rds_subnet_cidrs
  application_name         = var.application_name
  environment              = var.environment
}

module "web_servers" {
  source = "../modules/web_servers"
  application_name = var.application_name
  environment = var.environment
  public_subnet_ids = module.vpc.ec2_public_subnet_ids
  public_subnets_cidr_blocks = var.ec2_public_subnet_cidrs
  web_servers_subnets_ids = module.vpc.ec2_private_subnet_ids
  web_servers_vpc_id = module.vpc.ec2_vpc_id
  depends_on = [module.vpc]
}

module "ec2_jenkins" {
  source = "../modules/ec2_jenkins"

  application_name     = var.application_name
  ec2_jenkins_subnet_ids = module.vpc.ec2_public_subnet_ids
  environment          = var.environment
  ec2_jenkins_vpc_id     = module.vpc.ec2_vpc_id
  depends_on = [module.vpc]
}

module "rds" {
  source = "../modules/rds"
  application_name = var.application_name
  environment = var.environment
  rds_instance_class = var.rds_instance_class
  rds_subnet_ids = module.vpc.rds_subnet_ids
  rds_vpc_id = module.vpc.rds_vpc_id
  web_servers_cidrs = var.ec2_private_subnet_cidrs
}



