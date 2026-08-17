data "aws_eks_addon_version" "vpc_cni_east" {
  provider = aws.east

  addon_name         = "vpc-cni"
  kubernetes_version = module.eks_east.cluster_version
  most_recent        = true
}

resource "aws_eks_addon" "vpc_cni_east" {
  provider = aws.east

  cluster_name  = module.eks_east.cluster_name
  addon_name    = "vpc-cni"
  addon_version = data.aws_eks_addon_version.vpc_cni_east.version

  configuration_values = jsonencode({
    env = {
      ENABLE_PREFIX_DELEGATION = "true"
      WARM_PREFIX_TARGET       = "1"
    }
  })

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  depends_on = [
    module.eks_east
  ]
}