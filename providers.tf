terraform {
  required_version = ">= 1.11.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.90.1, < 6.0.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }

    kubectl = {
      source  = "hashicorp-oss/kubectl"
      version = "~> 0.1"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }
}

########################################
# AWS Providers
########################################

provider "aws" {
  alias  = "east"
  region = var.regions.east
}

provider "aws" {
  alias  = "west"
  region = var.regions.west
}

########################################
# Kubectl Provider
########################################

provider "kubectl" {
  alias = "east"

  load_config_file = false

  host  = module.eks_east.cluster_endpoint
  token = data.aws_eks_cluster_auth.east.token
  cluster_ca_certificate = base64decode(
    module.eks_east.cluster_certificate_authority_data
  )
}