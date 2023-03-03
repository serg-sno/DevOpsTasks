#-------------------------------------------------------------------------------------------------
# Description : CICD creation
# Author      : Sergey Sakhno
#-------------------------------------------------------------------------------------------------

output "cicd_pipeline_arn" {
  value = module.cicd.cicd_pipeline_arn
}
