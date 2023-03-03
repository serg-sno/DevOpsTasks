#-------------------------------------------------------------------------------------------------
# Description : CICD creation
# Author      : Sergey Sakhno
#-------------------------------------------------------------------------------------------------

resource "aws_iam_role" "codebuild_deploy" {
  name_prefix = "${var.application_name}-${var.environment}-codebuild-deploy-"
  path = "/service-role/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_deploy" {
  name_prefix = "${var.application_name}-${var.environment}-codebuild-deploy-"
  role = aws_iam_role.codebuild_deploy.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": [
              "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${local.codebuild_deploy_project_name}",
              "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${local.codebuild_deploy_project_name}:*"
            ],
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketAcl",
                "s3:GetBucketLocation"
            ],
            "Resource": [
              "${aws_s3_bucket.codepipeline_bucket.arn}",
              "${aws_s3_bucket.codepipeline_bucket.arn}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "codebuild:CreateReportGroup",
                "codebuild:CreateReport",
                "codebuild:UpdateReport",
                "codebuild:BatchPutTestCases",
                "codebuild:BatchPutCodeCoverages"
            ],
            "Resource": [
                "arn:aws:codebuild:${var.aws_region}:${data.aws_caller_identity.current.account_id}:report-group/${local.codebuild_build_project_name}-*"
            ]
        },
        {
            "Sid": "AllowGetDockerImageFromECR",
            "Action": [
                "ecr:BatchCheckLayerAvailability",
                "ecr:BatchGetImage",
                "ecr:CompleteLayerUpload",
                "ecr:GetAuthorizationToken",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Sid": "AllowEKSAccess",
            "Effect": "Allow",
            "Action": [
                "eks:DescribeNodegroup",
                "eks:DescribeUpdate",
                "eks:DescribeCluster"
            ],
            "Resource": [
              "arn:aws:eks:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/${var.eks_cluster_name}"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role" "codebuild_deploy_kube" {
  name_prefix = "${var.application_name}-${var.environment}-codebuild-deploy-eks-"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.codebuild_deploy.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_deploy_kube" {
  name_prefix = "${var.application_name}-${var.environment}-codebuild-deploy-eks-"
  role = aws_iam_role.codebuild_deploy_kube.id
  #"arn:aws:eks:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/${var.eks_cluster_name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowEKSAccess",
            "Effect": "Allow",
            "Action": [
                "eks:DescribeNodegroup",
                "eks:DescribeUpdate",
                "eks:DescribeCluster",
                "eks:*"
            ],
            "Resource": [
              "*"
            ]
        }
    ]
}
EOF
}

resource "null_resource" "k8s_auth" {
  provisioner "local-exec" {
    command = "chmod +x modules/CICD/kube_aws_auth.sh; modules/CICD/kube_aws_auth.sh ${aws_iam_role.codebuild_deploy_kube.arn}"
  }
}
