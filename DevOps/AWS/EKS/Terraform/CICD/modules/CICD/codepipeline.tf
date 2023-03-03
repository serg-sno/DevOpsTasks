#-------------------------------------------------------------------------------------------------
# Description : CICD creation
# Author      : Sergey Sakhno
#-------------------------------------------------------------------------------------------------

locals {
  codepipeline_name = "${var.application_name}-${var.environment}"
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket_prefix = lower("${local.codepipeline_name}-artifacts-")
}

resource "aws_s3_bucket_acl" "codepipeline_bucket_acl" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  acl    = "private"
}

resource "aws_codepipeline" "codepipeline" {
  name     = local.codepipeline_name
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      run_order        = 1
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.git_hub_connection_arn
        FullRepositoryId = var.git_hub_repository_id
        BranchName       = var.git_hub_branch_name
      }
    }
  }

  stage {
    name = "Build"


    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "Deploy"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = []
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.deploy.name
      }
    }
  }
}