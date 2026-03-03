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
provider "helm" "west" {
  count = var.enable_west ? 1 : 0

  kubernetes {
    host                   = module.eks_west[0].cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_west[0].cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.west[0].token
  }
}

