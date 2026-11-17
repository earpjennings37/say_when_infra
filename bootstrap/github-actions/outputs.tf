output "github_actions_role_arn" {
  description = "Set as the AWS_ROLE_ARN repository variable in say_when_app."
  value       = aws_iam_role.github_actions_push.arn
}

output "ecr_repository_url" {
  description = "Where CI pushes the app image."
  value       = aws_ecr_repository.app.repository_url
}