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
  region = var.regions["east"]
}
provider "aws" {
  alias  = "west"
  region = var.regions["west"]
}

provider "helm" {
  alias = "east"
  kubernetes {
    host                   = module.eks_east.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_east.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.east.token
  }
}
provider "helm" {
  alias = "west"
  kubernetes {
    host                   = module.eks_west.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_west.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.west.token
  }
}