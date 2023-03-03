#-------------------------------------------------------------------------------------------------
# Description : CICD creation
# Author      : Sergey Sakhno
#-------------------------------------------------------------------------------------------------

locals {
  codebuild_deploy_project_name = "${var.application_name}-${var.environment}-deploy"
}

resource "aws_codebuild_project" "deploy" {
  name          = local.codebuild_deploy_project_name
  description   = "Deploy docker image to EKS"
  build_timeout = "5"
  service_role  = aws_iam_role.codebuild_deploy.arn

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
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }

    environment_variable {
      name  = "EKS_CLUSTER_NAME"
      value = var.eks_cluster_name
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = aws_ecr_repository.this.repository_url
    }

    environment_variable {
      name  = "APP_NAME"
      value = var.application_name
    }

    environment_variable {
      name  = "ENV"
      value = var.environment
    }

    environment_variable {
      name  = "KUBE_CODEBUILD_ROLE_ARN"
      value = aws_iam_role.codebuild_deploy_kube.arn
      #value = aws_iam_role.codebuild_deploy.arn
    }

    environment_variable {
      name  = "NAMESPACE"
      value = lower("${var.application_name}-${var.environment}")
    }

    environment_variable {
      name  = "RESOURCE_NAME"
      value = lower("${var.application_name}-${var.environment}")
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = "/aws/codebuild/${local.codebuild_deploy_project_name}"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "DevOps/AWS/EKS/buildspec-deploy.yml"
  }

  tags = {
    Environment = "Test"
  }

  provisioner "local-exec" {
    when    = destroy
    command = lower("helm uninstall ${self.environment[0].environment_variable[index(self.environment[0].environment_variable.*.name, "RESOURCE_NAME")].value} --wait")
  }
}