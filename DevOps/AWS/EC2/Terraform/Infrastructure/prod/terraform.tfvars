#-------------------------------------------------------------------------------------------------
# Description : Infrastructure creation in prod environment
# Author      : Sergey Sakhno
#-------------------------------------------------------------------------------------------------

aws_region               = "eu-central-1"
ec2_vpc_cidr             = "10.0.0.0/22"
ec2_public_subnet_cidrs  = ["10.0.0.0/24", "10.0.1.0/24"]
ec2_private_subnet_cidrs = ["10.0.2.0/24", "10.0.3.0/24"]
ec2_instance_type        = "t3.micro"
rds_vpc_cidr             = "10.0.4.0/22"
rds_subnet_cidrs         = ["10.0.4.0/24", "10.0.5.0/24"]
rds_instance_class       = "db.t3.micro"
application_name         = "DevOpsTasks"
environment              = "prod"