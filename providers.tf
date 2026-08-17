terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubectl = {
      source  = "hashicorp-oss/kubectl"
      version = "~> 0.1"
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
  #count  = var.enable_west ? 1 : 0
}
provider "kubectl" {
  alias = "east"

  # Load kubeconfig from default location
  load_config_file = false

  # Or specify explicit cluster connection details
  host                   = module.eks_east.cluster_endpoint
  token                  = data.aws_eks_cluster_auth.east.token
  cluster_ca_certificate = base64decode(module.eks_east.cluster_certificate_authority_data)
}