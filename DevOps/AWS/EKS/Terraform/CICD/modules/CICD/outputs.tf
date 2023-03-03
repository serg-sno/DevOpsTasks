#-------------------------------------------------------------------------------------------------
# Description : CICD creation
# Author      : Sergey Sakhno
#-------------------------------------------------------------------------------------------------

output "cicd_pipeline_arn" {
  value = aws_codepipeline.codepipeline.arn
}