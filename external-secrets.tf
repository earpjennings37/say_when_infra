# ============================================================
# External Secrets Operator
# AWS Secrets Manager + EKS Pod Identity
# ============================================================

locals {
  external_secrets_namespace       = "external-secrets"
  external_secrets_service_account = "external-secrets"

  demo_secret_name = "say-when/demo-app/credentials"
}


# ------------------------------------------------------------
# EKS Pod Identity Agent
# ------------------------------------------------------------

data "aws_eks_addon_version" "pod_identity_agent_east" {
  provider = aws.east

  addon_name         = "eks-pod-identity-agent"
  kubernetes_version = module.eks_east.cluster_version
  most_recent        = true
}

resource "aws_eks_addon" "pod_identity_agent_east" {
  provider = aws.east

  cluster_name  = module.eks_east.cluster_name
  addon_name    = "eks-pod-identity-agent"
  addon_version = data.aws_eks_addon_version.pod_identity_agent_east.version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  depends_on = [
    module.eks_east
  ]
}


# ------------------------------------------------------------
# Dummy application credentials
#
# The generated password is ephemeral and is passed through
# the AWS provider's write-only secret_string_wo argument.
# It is not persisted in Terraform state.
# ------------------------------------------------------------

ephemeral "random_password" "demo_app" {
  length           = 32
  special          = true
  override_special = "!#$%&*+-=?@_"
}

resource "aws_secretsmanager_secret" "demo_app" {
  provider = aws.east

  name        = local.demo_secret_name
  description = "Temporary demo application credentials for External Secrets Operator"

  # Permanently delete the secret during terraform destroy.
  # This prevents ongoing charges while the lab is destroyed.
  recovery_window_in_days = 0

  tags = {
    Name      = local.demo_secret_name
    ManagedBy = "Terraform"
    Purpose   = "external-secrets-demo"
  }
}

resource "aws_secretsmanager_secret_version" "demo_app" {
  provider = aws.east

  secret_id = aws_secretsmanager_secret.demo_app.id

  secret_string_wo = jsonencode({
    username = "demo-user"
    password = ephemeral.random_password.demo_app.result
  })

  # Increment this value when intentionally rotating the secret.
  secret_string_wo_version = 1
}


# ------------------------------------------------------------
# EKS Pod Identity trust policy
# ------------------------------------------------------------

data "aws_iam_policy_document" "external_secrets_pod_identity_assume" {
  provider = aws.east

  statement {
    sid    = "AllowEksPodIdentity"
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "external_secrets" {
  provider = aws.east

  name = "external-secrets-pod-identity-role"

  assume_role_policy = data.aws_iam_policy_document.external_secrets_pod_identity_assume.json

  tags = {
    Name      = "external-secrets-pod-identity-role"
    ManagedBy = "Terraform"
  }
}


# ------------------------------------------------------------
# Narrow Secrets Manager read policy
# ------------------------------------------------------------

data "aws_iam_policy_document" "external_secrets" {
  provider = aws.east

  statement {
    sid    = "ReadDemoApplicationSecret"
    effect = "Allow"

    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue"
    ]

    resources = [
      aws_secretsmanager_secret.demo_app.arn
    ]
  }
}

resource "aws_iam_policy" "external_secrets" {
  provider = aws.east

  name        = "external-secrets-demo-secret-read"
  description = "Allows External Secrets Operator to read only the demo application secret"
  policy      = data.aws_iam_policy_document.external_secrets.json

  tags = {
    Name      = "external-secrets-demo-secret-read"
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "external_secrets" {
  provider = aws.east

  role       = aws_iam_role.external_secrets.name
  policy_arn = aws_iam_policy.external_secrets.arn
}


# ------------------------------------------------------------
# Associate the ESO service account with the IAM role
# ------------------------------------------------------------

resource "aws_eks_pod_identity_association" "external_secrets" {
  provider = aws.east

  cluster_name    = module.eks_east.cluster_name
  namespace       = local.external_secrets_namespace
  service_account = local.external_secrets_service_account
  role_arn        = aws_iam_role.external_secrets.arn

  depends_on = [
    aws_eks_addon.pod_identity_agent_east,
    aws_iam_role_policy_attachment.external_secrets
  ]
}