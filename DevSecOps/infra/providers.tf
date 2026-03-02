terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}
provider "aws" {
  alias  = "east"
  region = var.regions.east
}
provider "aws" {
  alias  = "west"
  region = var.regions.west
}
##############################
# HELM PROVIDER — EAST
##############################
provider "helm" {
  alias = "east"
  kubernetes {
    host                   = module.eks_east.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_east.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.east.token
  }
}
##############################
# HELM PROVIDER — WEST (optional)
##############################
provider "helm" {
  alias = "west"
  kubernetes {
    host                   = local.eks_west_endpoint
    cluster_ca_certificate = local.eks_west_ca
    token                  = local.eks_west_token
  }
}
