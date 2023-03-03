#-------------------------------------------------------------------------------------------------
# Description : CICD creation
# Author      : Sergey Sakhno
#-------------------------------------------------------------------------------------------------

locals {
  codebuild_build_project_name = "${var.application_name}-${var.environment}-build"
}

resource "aws_codebuild_project" "build" {
  name          = local.codebuild_build_project_name
  description   = "Build docker image"
  build_timeout = "5"
  service_role  = aws_iam_role.codebuild_build.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type = "NO_CACHE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = aws_ecr_repository.this.name
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = "/aws/codebuild/${local.codebuild_build_project_name}"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "DevOps/AWS/EKS/buildspec-build.yml"
  }

  tags = {
    Environment = "Test"
  }
}