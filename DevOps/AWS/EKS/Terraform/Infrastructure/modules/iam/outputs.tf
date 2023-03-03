#-------------------------------------------------------------------------------------------------
# Description : Additional IAM policy for EKS cluster private node group
# Author      : Sergey Sakhno
#-------------------------------------------------------------------------------------------------

output "private_node_group_policy_arn" {
  value = aws_iam_policy.eks_private_node_group_policy.arn
}

