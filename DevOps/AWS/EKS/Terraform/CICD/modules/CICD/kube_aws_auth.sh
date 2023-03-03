#!/bin/sh
#-------------------------------------------------------------------------------------------------
# Description : aws_auth configmap patch
# Author      : Sergey Sakhno
#-------------------------------------------------------------------------------------------------

EKS_CODEBUILD_KUBECTL_ROLE_ARN=$1
ROLE="    - rolearn: $EKS_CODEBUILD_KUBECTL_ROLE_ARN\n      username: build\n      groups:\n        - system:masters"

kubectl get -n kube-system configmap/aws-auth -o yaml | awk "/mapRoles: \|/{print;print \"$ROLE\";next}1" > /tmp/aws-auth-patch.yml

kubectl patch configmap/aws-auth -n kube-system --patch "$(cat /tmp/aws-auth-patch.yml)"