output "hcp_oidc_provider_arn" {
  description = "ARN of the HCP Terraform OIDC identity provider"
  value       = aws_iam_openid_connect_provider.hcp_terraform.arn
}

output "hcp_terraform_role_arn" {
  description = "IAM role ARN used by the HCP Terraform workspace"
  value       = aws_iam_role.hcp_terraform.arn
}

output "hcp_subject_pattern" {
  description = "HCP workload identity subject allowed by the trust policy"

  value = join(":", [
    "organization",
    var.hcp_organization,
    "project",
    var.hcp_project,
    "workspace",
    var.hcp_workspace,
    "run_phase",
    "*"
  ])
}