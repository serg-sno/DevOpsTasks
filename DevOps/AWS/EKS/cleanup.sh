#!/bin/sh
#-------------------------------------------------------------------------------------------------
# Description : Clean up script
# Author      : Sergey Sakhno
#-------------------------------------------------------------------------------------------------

cd Terraform/CICD
terraform destroy -auto-approve
cd "../AWS Load Balancer Controller"
terraform destroy -auto-approve
cd ../Infrastructure
terraform destroy -auto-approve
