#-------------------------------------------------------------------------------------------------
# Description : IAM role for EC2 web servers
# Author      : Sergey Sakhno
#-------------------------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "webserver" {
  name_prefix = "${var.application_name}-${var.environment}-webserver"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sts:AssumeRole"
        ],
        "Principal" : {
          "Service" : [
            "ec2.amazonaws.com"
          ]
        }
      }
    ]
  })

  tags = {
    Application = var.application_name
    Environment = var.environment
    Service     = "WebServer"
  }
}

resource "aws_iam_role_policy" "webserver" {
  name_prefix = "${var.application_name}-${var.environment}-webserver"
  role        = aws_iam_role.webserver.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ssm:GetParameterHistory",
          "ssm:GetParametersByPath",
          "ssm:GetParameters",
          "ssm:GetParameter"
        ],
        "Resource": [
          "arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:parameter/config/*"
        ]
      }
    ]
  })
}
