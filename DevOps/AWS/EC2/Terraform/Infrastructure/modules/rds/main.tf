#-------------------------------------------------------------------------------------------------
# Description : RDS creation
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

resource "aws_security_group" "rds" {
  vpc_id = var.rds_vpc_id
  ingress {
    from_port   = 5432
    protocol    = "tcp"
    to_port     = 5432
    cidr_blocks = var.web_servers_cidrs
  }
  tags = {
    Application = var.application_name
    Environment = var.environment
  }
}

resource "aws_db_subnet_group" "rds" {
  subnet_ids = var.rds_subnet_ids
  tags = {
    Application = var.application_name
    Environment = var.environment
  }
}

data "aws_ssm_parameter" "db_username" {
  name = "/config/${var.application_name}_${var.environment}/db.username"
}

data "aws_ssm_parameter" "db_password" {
  name = "/config/${var.application_name}_${var.environment}/db.password"
}

resource "aws_db_instance" "rds" {
  instance_class           = var.rds_instance_class
  identifier               = lower("db-${var.application_name}-${var.environment}")
  vpc_security_group_ids   = [aws_security_group.rds.id]
  allocated_storage        = 5
  db_subnet_group_name     = aws_db_subnet_group.rds.name
  engine                   = "Postgres"
  username                 = data.aws_ssm_parameter.db_username.value
  password                 = data.aws_ssm_parameter.db_password.value
  delete_automated_backups = true
  skip_final_snapshot      = true
  tags = {
    Application = var.application_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "db_url" {
  name  = "/config/${var.application_name}_${var.environment}/db.url"
  type  = "String"
  value = "jdbc:postgresql://${aws_db_instance.rds.endpoint}/postgres"
  tags = {
    Application = var.application_name
    Environment = var.environment
  }
}