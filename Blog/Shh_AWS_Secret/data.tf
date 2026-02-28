data "aws_secretsmanager_secret_version" "app_config" {
  secret_id = aws_secretsmanager_secret.app_config.id

  depends_on = [
    aws_secretsmanager_secret_version.app_config
  ]
}