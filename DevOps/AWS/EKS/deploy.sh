#!/bin/sh
#-------------------------------------------------------------------------------------------------
# Description : Deploy all
# Author      : Sergey Sakhno
#-------------------------------------------------------------------------------------------------

cd Terraform/Infrastructure
terraform init
terraform apply -auto-approve
cd "../AWS Load Balancer Controller"
terraform init
terraform apply -auto-approve
cd ../CICD
terraform init
terraform apply -auto-approve
