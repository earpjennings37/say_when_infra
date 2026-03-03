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
