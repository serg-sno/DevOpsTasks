#-------------------------------------------------------------------------------------------------
# Description : Additional IAM policy for EKS cluster private node group
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

data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "eks_private_node_group_policy" {
  name_prefix = "${var.cluster_name}-PrivateNodeGroupPolicy"
  tags = {
    Application = var.application_name
  }
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
