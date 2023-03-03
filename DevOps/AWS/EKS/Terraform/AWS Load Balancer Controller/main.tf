#-------------------------------------------------------------------------------------------------
# Description : AWS Loadbalancer controller for EKS installation
# Author      : Sergey Sakhno
#-------------------------------------------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    helm       = {}
    kubernetes = {}
  }
}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

data "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_name
}

data "aws_caller_identity" "current" {}

locals {
  eks_oidc_provider     = try(replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", ""), null)
  eks_oidc_provider_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.eks_oidc_provider}"
}

resource "kubernetes_service_account" "this" {
  metadata {
    labels = {
      "app.kubernetes.io/component" : "controller"
      "app.kubernetes.io/name" : "aws-load-balancer-controller"
    }
    name        = "aws-load-balancer-controller"
    namespace   = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" : aws_iam_role.load_balancer_controller.arn
    }
  }
  automount_service_account_token = true
  depends_on = [aws_iam_role_policy.load_balancer_controller, aws_iam_role.load_balancer_controller]
}

resource "helm_release" "load_balancer_controller" {
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = var.eks_cluster_name
  }
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  depends_on = [kubernetes_service_account.this]
}

