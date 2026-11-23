# ============================================================
# Say When app settings (Fall #3)
#
# One secret, read by External Secrets Operator and synced into
# the say-when namespace. The app reads it as a mounted file.
#
# The token is generated ephemerally and written with the
# write-only secret_string_wo argument: it is never stored in
# Terraform state or plan output.
#
# Lifetime: tied to the cluster workspace. Destroyed with
# recovery_window_in_days = 0, so every rebuild gets a fresh token.
#
# Sources:
# https://developer.hashicorp.com/terraform/language/resources/ephemeral
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version
# https://docs.aws.amazon.com/secretsmanager/latest/userguide/auth-and-access_examples.html
# ============================================================

locals {
  app_settings_secret_name = "say-when/app/settings"
}

# URL- and header-safe: letters and digits only, 48 characters.
ephemeral "random_password" "say_when_admin_token" {
  length  = 48
  special = false
}

resource "aws_secretsmanager_secret" "say_when_app_settings" {
  provider = aws.east

  name        = local.app_settings_secret_name
  description = "Say When app settings (admin token), synced by External Secrets"

  # Delete immediately on destroy: no 7-30 day recovery charges
  # while the lab is torn down.
  recovery_window_in_days = 0

  tags = {
    Name      = local.app_settings_secret_name
    ManagedBy = "Terraform"
    App       = "say-when"
  }
}

resource "aws_secretsmanager_secret_version" "say_when_app_settings" {
  provider = aws.east

  secret_id = aws_secretsmanager_secret.say_when_app_settings.id

  secret_string_wo = jsonencode({
    admin_token = ephemeral.random_password.say_when_admin_token.result
  })

  # Increment to rotate the token on purpose.
  secret_string_wo_version = 1
}

# ------------------------------------------------------------
# Let External Secrets read THIS secret only.
# A separate policy, so the existing demo policy is untouched.
# ------------------------------------------------------------

data "aws_iam_policy_document" "external_secrets_say_when_app" {
  provider = aws.east

  statement {
    sid    = "ReadSayWhenAppSettings"
    effect = "Allow"

    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue"
    ]

    resources = [
      aws_secretsmanager_secret.say_when_app_settings.arn
    ]
  }
}

resource "aws_iam_policy" "external_secrets_say_when_app" {
  provider = aws.east

  name        = "external-secrets-say-when-app-read"
  description = "Allows External Secrets Operator to read only the say-when app settings secret"
  policy      = data.aws_iam_policy_document.external_secrets_say_when_app.json

  tags = {
    Name      = "external-secrets-say-when-app-read"
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "external_secrets_say_when_app" {
  provider = aws.east

  role       = aws_iam_role.external_secrets.name
  policy_arn = aws_iam_policy.external_secrets_say_when_app.arn
}