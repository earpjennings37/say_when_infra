data "aws_iam_policy_document" "k8sgpt_bedrock" {
  statement {
    sid = "InvokeNovaLite"

    actions = [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream"
    ]

    resources = [
      "arn:aws:bedrock:us-east-1::foundation-model/amazon.nova-lite-v1:0"
    ]
  }
}

resource "aws_iam_policy" "k8sgpt_bedrock" {
  name        = "k8sgpt-bedrock-policy"
  description = "Allows K8sGPT to invoke Amazon Nova Lite through Bedrock"
  policy      = data.aws_iam_policy_document.k8sgpt_bedrock.json
}

data "aws_iam_policy_document" "k8sgpt_irsa_assume" {
  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

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
        "system:serviceaccount:k8sgpt-operator-system:k8sgpt-bedrock"
      ]
    }
  }
}

resource "aws_iam_role" "k8sgpt_irsa" {
  name               = "k8sgpt-bedrock-irsa-role"
  assume_role_policy = data.aws_iam_policy_document.k8sgpt_irsa_assume.json
}

resource "aws_iam_role_policy_attachment" "k8sgpt_bedrock" {
  role       = aws_iam_role.k8sgpt_irsa.name
  policy_arn = aws_iam_policy.k8sgpt_bedrock.arn
}