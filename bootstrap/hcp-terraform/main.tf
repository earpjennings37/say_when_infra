data "aws_partition" "current" {}

resource "aws_iam_openid_connect_provider" "hcp_terraform" {
  url = "https://${var.hcp_hostname}"

  client_id_list = [
    "aws.workload.identity"
  ]

  tags = {
    Name      = "hcp-terraform"
    ManagedBy = "Terraform"
    Purpose   = "HCP Terraform dynamic credentials"
  }
}

data "aws_iam_policy_document" "hcp_terraform_assume_role" {
  statement {
    sid    = "AllowHcpTerraformWorkspace"
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.hcp_terraform.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.hcp_hostname}:aud"

      values = [
        "aws.workload.identity"
      ]
    }

    condition {
      test     = "StringLike"
      variable = "${var.hcp_hostname}:sub"

      values = [
        "organization:${var.hcp_organization}:project:${var.hcp_project}:workspace:${var.hcp_workspace}:run_phase:*"
      ]
    }
  }
}

resource "aws_iam_role" "hcp_terraform" {
  name                 = "HCP-Terraform-say-when-infra"
  description          = "HCP Terraform OIDC role for the say_when_infra workspace"
  assume_role_policy   = data.aws_iam_policy_document.hcp_terraform_assume_role.json
  max_session_duration = 3600

  tags = {
    Name      = "HCP-Terraform-say-when-infra"
    ManagedBy = "Terraform"
    Purpose   = "HCP Terraform remote runs"
  }
}

resource "aws_iam_role_policy_attachment" "hcp_terraform_administrator" {
  role = aws_iam_role.hcp_terraform.name

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AdministratorAccess"
}