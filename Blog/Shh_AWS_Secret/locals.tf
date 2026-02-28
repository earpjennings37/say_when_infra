locals {
  db = {
    table_name = aws_dynamodb_table.app.name
    table_arn  = aws_dynamodb_table.app.arn
  }

  app_config = jsondecode(data.aws_secretsmanager_secret_version.app_config.secret_string)
}