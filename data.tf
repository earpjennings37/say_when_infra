data "aws_caller_identity" "current" {
}

##############################
# EAST AUTH
##############################
data "aws_eks_cluster_auth" "east" {
  provider = aws.east

  # A plain string, not module.eks_east.cluster_name. Referencing the module
  # makes Terraform defer this read whenever the cluster has a pending change,
  # so plan refreshes Argo CD with no token (401 "provide credentials").
  # Minting a token doesn't call the cluster, so this also works before the
  # cluster exists.
  name = local.eks_east_name
}
##############################
# WEST AUTH (optional)
#############################
data "aws_eks_cluster_auth" "west" {
  count = var.enable_west ? 1 : 0
  name  = local.eks_west_name
}