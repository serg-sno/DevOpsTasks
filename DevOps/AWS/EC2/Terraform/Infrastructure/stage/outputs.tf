#-------------------------------------------------------------------------------------------------
# Description : Infrastructure creation (VPC, subnets, IGW, NAT Gateways, EC2 instances, RDS, ...)
# Author      : Sergey Sakhno
#-------------------------------------------------------------------------------------------------

output "aws_region" {
  value = var.aws_region
}

output "vpc_id" {
  value = module.vpc.ec2_vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.ec2_private_subnet_ids
}

output "public_subnet_ids" {
  value = module.vpc.ec2_public_subnet_ids
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "ec2_jenkins_public_ip" {
  value = module.ec2_jenkins.ec2_jenkins_public_ip
}
