##############################
# KUBERNETES PROVIDER — EAST
##############################
provider "kubernetes" {
  host                   = module.eks_east.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_east.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.east.token
}
##############################
# KUBERNETES PROVIDER — WEST (optional)
##############################
provider "kubernetes" {
  alias                  = "west"
  host                   = module.eks_west.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_west.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.west[0].token
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
    host                   = var.enable_west ? module.eks_west[0].cluster_endpoint : ""
    cluster_ca_certificate = var.enable_west ? base64decode(module.eks_west[0].cluster_certificate_authority_data) : ""
    token                  = var.enable_west ? data.aws_eks_cluster_auth.west[0].token : ""
  }
}
##############################
# KUBERNETES NAMESPACE — EAST
##############################
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}
##############################
# KUBERNETES NAMESPACE — WEST (optional)
##############################
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}