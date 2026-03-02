data "aws_caller_identity" "current" {
}
##############################
# EAST AUTH
##############################
data "aws_eks_cluster_auth" "east" {
  name = module.eks_east.cluster_name
}
##############################
# WEST AUTH (optional)
##############################
data "aws_eks_cluster_auth" "west" {
  count = var.enable_west ? 1 : 0
  name  = local.eks_west_name
}