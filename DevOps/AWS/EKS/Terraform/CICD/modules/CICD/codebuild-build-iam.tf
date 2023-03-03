#-------------------------------------------------------------------------------------------------
# Description : CICD creation
# Author      : Sergey Sakhno
#-------------------------------------------------------------------------------------------------

resource "aws_iam_role" "codebuild_build" {
  name_prefix = "${var.application_name}-${var.environment}-codebuild-build-"

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

resource "aws_iam_role_policy" "codebuild_build" {
  name_prefix = "${var.application_name}-${var.environment}-codebuild-build-"
  role = aws_iam_role.codebuild_build.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": [
              "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${local.codebuild_build_project_name}",
              "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${local.codebuild_build_project_name}:*"
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
            "Sid": "AllowPushDockerImageToECR",
            "Action": [
                "ecr:BatchCheckLayerAvailability",
                "ecr:CompleteLayerUpload",
                "ecr:GetAuthorizationToken",
                "ecr:InitiateLayerUpload",
                "ecr:PutImage",
                "ecr:UploadLayerPart"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}