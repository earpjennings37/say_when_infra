resource "aws_secretsmanager_secret" "app_config" {
  name       = "app-config"
  kms_key_id = aws_kms_key.secrets.arn
}

resource "aws_secretsmanager_secret_version" "app_config" {
  secret_id     = aws_secretsmanager_secret.app_config.id
  secret_string = jsonencode({
    jwt_secret = "change-me"
  })
}