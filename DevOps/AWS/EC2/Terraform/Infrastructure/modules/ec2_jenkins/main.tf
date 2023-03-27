#-------------------------------------------------------------------------------------------------
# Description : EC2 jenkins server
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

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "jenkins" {
  name        = "ssh_http"
  description = "Allow SSH HTTP inbound traffic"
  vpc_id      = var.ec2_jenkins_vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Application = var.application_name
    Environment = var.environment
    Service     = "Jenkins"
  }
}

resource "aws_iam_instance_profile" "ec2_jenkins" {
  name_prefix = "ec2-jenkins-"
  role  = aws_iam_role.ec2_jenkins.name
}

resource "aws_instance" "jenkins" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = var.ec2_jenkins_instance_type
  subnet_id            = var.ec2_jenkins_subnet_ids[0]
  security_groups      = [aws_security_group.jenkins.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_jenkins.name
  key_name = "devopstasks-${var.environment}-key"


  user_data = <<EOF
#!/bin/bash
echo "****************** Installing Java **********************"
apt-get update
apt-get install openjdk-17-jre -y
java -version

echo "****************** Installing Jenkins *******************"
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
apt-get update
apt-get install jenkins -y

echo "****************** Installing Docker *******************"
apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
VERSION_STRING=5:23.0.1-1~ubuntu.22.04~jammy
apt-get install docker-ce=$VERSION_STRING docker-ce-cli=$VERSION_STRING containerd.io docker-buildx-plugin docker-compose-plugin -y

usermod -a -G docker jenkins

echo "****************** Installing psql *******************"
apt-get install -y postgresql-client

echo "****************** Installing ansible ****************"
apt-get install python3-pip -y
pip install botocore
pip install boto3

apt-get update
apt-get install software-properties-common
add-apt-repository --yes --update ppa:ansible/ansible
apt-get install ansible -y

ansible-galaxy collection install amazon.aws
EOF

  tags = {
    Name        = "jenkins"
    Application = var.application_name
    Environment = var.environment
    Service     = "Jenkins"
  }
}

# Elastic ip for jenkins server
resource "aws_eip" "jenkins" {
  vpc = true
  instance = aws_instance.jenkins.id
  tags = {
    Name        = "jenkins"
    Application = var.application_name
    Environment = var.environment
    Service     = "Jenkins"
  }
}