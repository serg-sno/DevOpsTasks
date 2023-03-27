#-------------------------------------------------------------------------------------------------
# Description : EC2 jenkins server
# Author      : Sergey Sakhno
#-------------------------------------------------------------------------------------------------

output "ec2_jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}