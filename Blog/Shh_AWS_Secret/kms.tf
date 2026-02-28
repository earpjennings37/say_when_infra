resource "aws_kms_key" "secrets" {
  description             = "KMS key for Secrets Manager secrets"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}

resource "aws_kms_alias" "secrets" {
  name          = "alias/wyatt-secrets"
  target_key_id = aws_kms_key.secrets.key_id
}