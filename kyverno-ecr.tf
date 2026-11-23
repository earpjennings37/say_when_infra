# ============================================================
# Kyverno: read-only ECR access for image signature checks (Fall #3)
#
# The signed-images-only policy makes Kyverno fetch each image's
# Cosign signature from ECR at admission. Kyverno's built-in AWS
# credential helper uses the standard credential chain, which
# picks up EKS Pod Identity: no keys, no imagePullSecrets.
#
# The ECR repo belongs to bootstrap/github-actions (separate
# state), so it is looked up by name here, not managed.
#
# Sources:
# https://kyverno.io/docs/policy-types/image-validating-policy/
# https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html
# https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-signing.html
# ============================================================

locals {
  kyverno_namespace = "kyverno"

  # Components that verify images: at admission, and in background reports.
  kyverno_image_verify_service_accounts = [
    "kyverno-admission-controller",
    "kyverno-reports-controller",
  ]
}

data "aws_ecr_repository" "say_when_app" {
  provider = aws.east
  name     = "say-when-app"
}

data "aws_iam_policy_document" "kyverno_pod_identity_assume" {
  provider = aws.east

  statement {
    sid     = "AllowEksPodIdentity"
    effect  = "Allow"
    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "kyverno_ecr_read" {
  provider = aws.east

  name               = "kyverno-ecr-read-pod-identity-role"
  assume_role_policy = data.aws_iam_policy_document.kyverno_pod_identity_assume.json

  tags = {
    Name      = "kyverno-ecr-read-pod-identity-role"
    ManagedBy = "Terraform"
  }
}

# Read-only, one repository. GetAuthorizationToken has no
# resource-level scoping in AWS, so it must be "*".
data "aws_iam_policy_document" "kyverno_ecr_read" {
  provider = aws.east

  statement {
    sid       = "EcrLogin"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "ReadSayWhenAppImagesAndSignatures"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:GetDownloadUrlForLayer",
      "ecr:ListImages",
    ]
    resources = [data.aws_ecr_repository.say_when_app.arn]
  }
}

resource "aws_iam_role_policy" "kyverno_ecr_read" {
  provider = aws.east

  name   = "ecr-read-say-when-app"
  role   = aws_iam_role.kyverno_ecr_read.id
  policy = data.aws_iam_policy_document.kyverno_ecr_read.json
}

resource "aws_eks_pod_identity_association" "kyverno_ecr_read" {
  provider = aws.east
  for_each = toset(local.kyverno_image_verify_service_accounts)

  cluster_name    = module.eks_east.cluster_name
  namespace       = local.kyverno_namespace
  service_account = each.value
  role_arn        = aws_iam_role.kyverno_ecr_read.arn

  depends_on = [
    aws_eks_addon.pod_identity_agent_east,
    aws_iam_role_policy.kyverno_ecr_read
  ]
}