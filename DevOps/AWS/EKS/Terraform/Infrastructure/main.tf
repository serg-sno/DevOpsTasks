#-------------------------------------------------------------------------------------------------
# Description : Infrastructure creation (VPC, subnets, IGW, NAT Gateways, EKS Cluster, ...)
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
  source                   = "./modules/vpc"
  eks_vpc_cidr             = var.eks_vpc_cidr
  eks_public_subnet_cidrs  = var.eks_public_subnet_cidrs
  eks_private_subnet_cidrs = var.eks_private_subnet_cidrs
  eks_cluster_name         = var.eks_cluster_name
  rds_vpc_cidr             = var.rds_vpc_cidr
  rds_subnet_cidrs         = var.rds_subnet_cidrs
  application_name         = var.application_name
}

module "iam" {
  source           = "./modules/iam"
  cluster_name     = var.eks_cluster_name
  application_name = var.application_name
}

module "eks_cluster" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "~> 19.0"
  cluster_name                    = var.eks_cluster_name
  cluster_version                 = "1.25"
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  create_node_security_group      = false
  vpc_id                          = module.vpc.eks_vpc_id
  subnet_ids                      = concat(module.vpc.eks_private_subnet_ids, module.vpc.eks_public_subnet_ids)

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    private = {
      min_size     = 2
      max_size     = 3
      desired_size = 3
      subnet_ids   = module.vpc.eks_private_subnet_ids

      instance_types                        = [var.eks_cluster_instance_type]
      capacity_type                         = "ON_DEMAND"
      attach_cluster_primary_security_group = true
      iam_role_additional_policies          = {
        private_node_group_policy_arn = module.iam.private_node_group_policy_arn
      }

      labels = {
        "subnet.type" = "private"
      }

      tags = {
        Application = var.application_name
      }
    }
    public = {
      min_size     = 2
      max_size     = 3
      desired_size = 2
      subnet_ids   = module.vpc.eks_public_subnet_ids

      instance_types                        = [var.eks_cluster_instance_type]
      capacity_type                         = "ON_DEMAND"
      attach_cluster_primary_security_group = true

      labels = {
        "subnet.type" = "public"
      }
      tags = {
        Application = var.application_name
      }
    }
  }
}

#RDS
resource "aws_security_group" "rds" {
  vpc_id = module.vpc.rds_vpc_id
  ingress {
    from_port   = 5432
    protocol    = "tcp"
    to_port     = 5432
    cidr_blocks = var.eks_private_subnet_cidrs
  }
}

resource "aws_db_subnet_group" "rds" {
  subnet_ids = module.vpc.rds_subnet_ids
}

data "aws_ssm_parameter" "db_username" {
  name = "/config/${var.application_name}_${var.environment}/db.username"
}

data "aws_ssm_parameter" "db_password" {
  name = "/config/${var.application_name}_${var.environment}/db.password"
}

resource "aws_db_instance" "rds" {
  instance_class           = "db.t3.micro"
  identifier               = lower("db-${var.application_name}-${var.environment}")
  vpc_security_group_ids   = [aws_security_group.rds.id]
  allocated_storage        = 5
  db_subnet_group_name     = aws_db_subnet_group.rds.name
  engine                   = "Postgres"
  username                 = data.aws_ssm_parameter.db_username.value
  password                 = data.aws_ssm_parameter.db_password.value
  delete_automated_backups = true
  skip_final_snapshot      = true
}

resource "aws_ssm_parameter" "db_url" {
  name  = "/config/${var.application_name}_${var.environment}/db.url"
  type  = "String"
  value = "jdbc:postgresql://${aws_db_instance.rds.endpoint}/postgres"
}

resource "null_resource" "create_kube_config" {
  depends_on = [module.eks_cluster]
  provisioner "local-exec" {
    command = "aws eks --region ${var.aws_region} update-kubeconfig --name ${module.eks_cluster.cluster_name}"
  }
}