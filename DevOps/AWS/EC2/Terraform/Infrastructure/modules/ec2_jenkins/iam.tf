#-------------------------------------------------------------------------------------------------
# Description : IAM role for EC2 jenkins server
# Author      : Sergey Sakhno
#-------------------------------------------------------------------------------------------------

resource "aws_iam_role" "ec2_jenkins" {
  name_prefix = "${var.application_name}-${var.environment}-ec2-jenkins-role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "sts:AssumeRole"
        ],
        "Principal": {
          "Service": [
            "ec2.amazonaws.com"
          ]
        }
      }
    ]
  })

  tags = {
    Application = var.application_name
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "ec2_jenkins" {
  name_prefix = "${var.application_name}-${var.environment}-ec2-jenkins-policy"
  role = aws_iam_role.ec2_jenkins.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "ec2:DescribeTags",
          "ec2:DescribeInstances"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  })
}