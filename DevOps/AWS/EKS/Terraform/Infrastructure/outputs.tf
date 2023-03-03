#-------------------------------------------------------------------------------------------------
# Description : Infrastructure creation (VPC, subnets, IGW, NAT Gateways, EKS Cluster, ...)
# Author      : Sergey Sakhno
#-------------------------------------------------------------------------------------------------

output "aws_region" {
  value = var.aws_region
}

output "vpc_id" {
  value = module.vpc.eks_vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.eks_private_subnet_ids
}

output "public_subnet_ids" {
  value = module.vpc.eks_public_subnet_ids
}

output "eks_cluster" {
  value = module.eks_cluster
}

output "rds_endpoint" {
  value = aws_db_instance.rds.endpoint
}

