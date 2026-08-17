data "aws_caller_identity" "current" {
}

data "aws_eks_cluster_auth" "east" {
  name = module.eks_east.cluster_name
}