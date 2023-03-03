#-------------------------------------------------------------------------------------------------
# Description : Infrastructure creation (VPC, subnets, IGW, NAT Gateways, EKS Cluster, ...)
# Author      : Sergey Sakhno
#-------------------------------------------------------------------------------------------------

aws_region                = "eu-central-1"
eks_vpc_cidr              = "10.0.0.0/22"
eks_public_subnet_cidrs   = ["10.0.0.0/24", "10.0.1.0/24"]
eks_private_subnet_cidrs  = ["10.0.2.0/24", "10.0.3.0/24"]
eks_cluster_name          = "eks-cluster"
eks_cluster_instance_type = "t3.micro"
rds_vpc_cidr              = "10.0.4.0/22"
rds_subnet_cidrs          = ["10.0.4.0/24", "10.0.5.0/24"]
rds_instance_class        = "db.t3.micro"
application_name          = "DevOpsTasks"
environment               = "prod"