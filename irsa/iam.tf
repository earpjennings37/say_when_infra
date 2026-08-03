data "aws_iam_policy_document" "thanos_irsa_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${aws_iam_openid_connect_provider.eks.url}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${aws_iam_openid_connect_provider.eks.url}:sub"
      values = [
        "system:serviceaccount:monitoring:prometheus-kube-prometheus-prometheus",
        "system:serviceaccount:monitoring:thanos-compactor",
        "system:serviceaccount:monitoring:thanos-storegateway"
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