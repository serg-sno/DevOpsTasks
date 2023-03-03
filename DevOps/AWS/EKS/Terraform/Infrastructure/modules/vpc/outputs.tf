#-------------------------------------------------------------------------------------------------
# Description : Network layer creation
# Author      : Sergey Sakhno
#-------------------------------------------------------------------------------------------------

output "eks_vpc_id" {
  value = aws_vpc.eks_vpc.id
}

output "eks_private_subnet_ids" {
  value = aws_subnet.eks_private[*].id
}

output "eks_public_subnet_ids" {
  value = aws_subnet.eks_public[*].id
}

output "rds_vpc_id" {
  value = aws_vpc.rds_vpc.id
}

output "rds_subnet_ids" {
  value = aws_subnet.rds[*].id
}
