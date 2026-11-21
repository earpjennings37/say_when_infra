data "aws_caller_identity" "current" {
}

##############################
# EAST AUTH
##############################
data "aws_eks_cluster_auth" "east" {
  name = module.eks_east.cluster_name

  # Read the token at apply time, after the cluster and node groups exist,
  # so the 15-minute token is still fresh when Helm installs Argo CD.
  # Without this, the token is minted at plan time and expires during
  # the ~20-minute EKS create.
  depends_on = [module.eks_east]
}
##############################
# WEST AUTH (optional)
#############################
data "aws_eks_cluster_auth" "west" {
  count = var.enable_west ? 1 : 0
  name  = local.eks_west_name
}