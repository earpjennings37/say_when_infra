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
variable "github_owner_id" {
  description = "Numeric GitHub account ID. Immutable: survives renames, never reused."
  type        = string
  default     = "177775312"
}

variable "github_repository_id" {
  description = "Numeric GitHub repository ID. Immutable."
  type        = string
  default     = "1460572719"
}