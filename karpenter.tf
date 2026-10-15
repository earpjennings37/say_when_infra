# ============================================================
# Karpenter
#
# AWS-side infrastructure for:
# - EKS Pod Identity
# - Controller IAM permissions
# - Spot interruption handling
# - Node provisioning permissions
#
# The Karpenter controller itself is installed separately
# through Argo CD from the GitOps repository.
# ============================================================

module "karpenter_east" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "20.37.2"

  providers = {
    aws = aws.east
  }

  cluster_name = module.eks_east.cluster_name

  # Must match the namespace and ServiceAccount created by
  # the Karpenter Helm chart through Argo CD.
  namespace       = "karpenter"
  service_account = "karpenter"

  # Use EKS Pod Identity for the Karpenter controller.
  enable_pod_identity             = true
  create_pod_identity_association = true

  # Required for Karpenter v1.x IAM permissions.
  enable_v1_permissions = true

  # Create the SQS queue and EventBridge rules for Spot
  # interruption and EC2 lifecycle notifications.
  enable_spot_termination = true

  # Reuse the IAM role from the existing EKS managed node group.
  # That role already has the required worker-node policies and
  # is authorized through the aws-auth ConfigMap.
  create_node_iam_role = false
  node_iam_role_arn    = module.eks_east.eks_managed_node_groups["prefix"].iam_role_arn

  # The cluster currently uses CONFIG_MAP authentication.
  # The reused node role is already authorized through aws-auth.
  create_access_entry = false

  # A stable instance profile is created separately below.
  create_instance_profile = false

  tags = merge(
    local.tags,
    {
      Component = "karpenter"
    }
  )

  depends_on = [
    aws_eks_addon.pod_identity_agent_east
  ]
}


# ============================================================
# Stable Karpenter Node Instance Profile
#
# The managed-node-group IAM role contains a generated suffix
# that changes after destroying and rebuilding the cluster.
#
# This instance profile keeps a stable name while attaching to
# the current managed-node-group IAM role.
# ============================================================

resource "aws_iam_instance_profile" "karpenter_nodes" {
  provider = aws.east

  name = "KarpenterNodeInstanceProfile-${local.eks_east_name}"
  role = module.eks_east.eks_managed_node_groups["prefix"].iam_role_name

  tags = merge(
    local.tags,
    {
      Component = "karpenter"
    }
  )
}

resource "aws_iam_role_policy" "karpenter_instance_profile_gc" {
  provider = aws.east

  name = "KarpenterInstanceProfileGarbageCollection"
  role = module.karpenter_east.iam_role_name

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid      = "AllowListingInstanceProfiles"
        Effect   = "Allow"
        Action   = "iam:ListInstanceProfiles"
        Resource = "*"
      }
    ]
  })
}