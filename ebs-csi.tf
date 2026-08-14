module "ebs_csi_irsa_role_east" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  providers = {
    aws = aws.east
  }

  role_name             = "${local.eks_east_name}-ebs-csi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    east = {
      provider_arn = module.eks_east.oidc_provider_arn

      namespace_service_accounts = [
        "kube-system:ebs-csi-controller-sa"
      ]
    }
  }
}

data "aws_eks_addon_version" "ebs_csi_east" {
  provider = aws.east

  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = module.eks_east.cluster_version
  most_recent        = true
}

resource "aws_eks_addon" "ebs_csi_east" {
  provider = aws.east

  cluster_name  = module.eks_east.cluster_name
  addon_name    = "aws-ebs-csi-driver"
  addon_version = data.aws_eks_addon_version.ebs_csi_east.version

  service_account_role_arn = module.ebs_csi_irsa_role_east.iam_role_arn

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"
}