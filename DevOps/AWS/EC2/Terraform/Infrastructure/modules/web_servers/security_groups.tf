#-------------------------------------------------------------------------------------------------
# Description : Security group for web servers
# Author      : Sergey Sakhno
#-------------------------------------------------------------------------------------------------

resource "aws_security_group" "web_server" {
  name        = "${var.application_name}-${var.environment}-webserver"
  description = "Allow HTTP inbound traffic"
  vpc_id      = var.web_servers_vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.public_subnets_cidr_blocks
  }

  ingress {
    description = "HTTP"
    from_port   = 5000
    to_port     = 5000
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
    Service     = "WebServer"
  }
}