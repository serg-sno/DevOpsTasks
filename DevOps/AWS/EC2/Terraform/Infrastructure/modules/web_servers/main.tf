#-------------------------------------------------------------------------------------------------
# Description : Web servers
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

resource "aws_lb_target_group" "this" {
  name = "${var.application_name}-${var.environment}"

  port        = 5000
  protocol    = "TCP"
  vpc_id      = var.web_servers_vpc_id
  tags = {
    Application = var.application_name
    Environment = var.environment
    Service = "WebServer"
  }
}

resource "aws_lb" "this" {
  name               = "${var.application_name}-${var.environment}-nlb"
  load_balancer_type = "network"
  subnets            = var.public_subnet_ids

  enable_cross_zone_load_balancing = true
  tags = {
    Application = var.application_name
    Environment = var.environment
    Service = "WebServer"
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn

  protocol          = "TCP"
  port              = 80

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
  depends_on = [aws_lb_target_group.this]
}

resource "aws_iam_instance_profile" "webservers" {
  name_prefix = "ec2-jenkins-"
  role  = aws_iam_role.webserver.name
}

resource "aws_instance" "web_server" {
  count = length(var.web_servers_subnets_ids)
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.web_servers_instance_type
  subnet_id = var.web_servers_subnets_ids[count.index]
  vpc_security_group_ids = [aws_security_group.web_server.id]
  key_name = "devopstasks-${var.environment}-key"
  iam_instance_profile = aws_iam_instance_profile.webservers.name


  user_data = <<EOF
#!/bin/bash
echo "****************** Installing Java **********************"
apt-get update
apt-get install openjdk-17-jre -y
java -version

EOF

  tags = {
    Name = "web_server"
    Application = var.application_name
    Environment = var.environment
    Service = "WebServer"
  }
}

resource "aws_lb_target_group_attachment" "this" {
  count = length(aws_instance.web_server)
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_instance.web_server[count.index].id
  port             = 5000
}