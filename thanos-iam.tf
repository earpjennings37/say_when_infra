data "aws_iam_policy_document" "thanos_irsa_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"

      identifiers = [
        module.eks_east.oidc_provider_arn
      ]
    }

    condition {
      test = "StringEquals"

      variable = "${replace(module.eks_east.cluster_oidc_issuer_url, "https://", "")}:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test = "StringEquals"

      variable = "${replace(module.eks_east.cluster_oidc_issuer_url, "https://", "")}:sub"

      values = [
        "system:serviceaccount:monitoring:prometheus-kube-prometheus-prometheus",
        "system:serviceaccount:monitoring:thanos-compactor",
        "system:serviceaccount:monitoring:thanos-storegateway",
        "system:serviceaccount:monitoring:thanos-query"
      ]
    }
  }
}

resource "aws_iam_role" "thanos_irsa" {
  name               = "thanos-irsa-role"
  assume_role_policy = data.aws_iam_policy_document.thanos_irsa_assume.json
}

resource "aws_iam_role_policy_attachment" "thanos_s3_attach" {
  role       = aws_iam_role.thanos_irsa.name
  policy_arn = aws_iam_policy.thanos_s3_policy.arn
}