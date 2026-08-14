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

##############################
# EAST AUTH
##############################
data "aws_eks_cluster_auth" "east" {
  provider = aws.east
  name     = module.eks_east.cluster_name
}
##############################
# WEST AUTH (optional)
##############################
data "aws_eks_cluster_auth" "west" {
  provider = aws.west
  count    = var.enable_west ? 1 : 0
  name     = local.eks_west_name
}