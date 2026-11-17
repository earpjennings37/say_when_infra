variable "region" {
  description = "AWS region for the app's ECR repository."
  type        = string
  default     = "us-east-1"
}

variable "github_repository" {
  description = "GitHub repository (owner/name) allowed to push images."
  type        = string
  default     = "earpjennings37/say_when_app"
}

variable "github_branch" {
  description = "Only workflows running on this branch can assume the push role."
  type        = string
  default     = "main"
}

variable "ecr_repository_name" {
  description = "Name of the app's ECR repository."
  type        = string
  default     = "say-when-app"
}