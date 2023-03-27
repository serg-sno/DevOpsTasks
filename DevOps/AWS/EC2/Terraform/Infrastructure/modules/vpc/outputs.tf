#-------------------------------------------------------------------------------------------------
# Description : Network layer creation
# Author      : Sergey Sakhno
#-------------------------------------------------------------------------------------------------

output "ec2_vpc_id" {
  value = aws_vpc.ec2_vpc.id
}

output "ec2_private_subnet_ids" {
  value = aws_subnet.ec2_private[*].id
}

output "ec2_public_subnet_ids" {
  value = aws_subnet.ec2_public[*].id
}

output "rds_vpc_id" {
  value = aws_vpc.rds_vpc.id
}

output "rds_subnet_ids" {
  value = aws_subnet.rds[*].id
}
