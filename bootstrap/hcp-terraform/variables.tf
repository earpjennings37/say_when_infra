variable "hcp_hostname" {
  description = "HCP Terraform hostname used as the OIDC issuer"
  type        = string
  default     = "app.terraform.io"
}

variable "hcp_organization" {
  description = "HCP Terraform organization allowed to assume the role"
  type        = string
  default     = "MyBlogJourney24"
}

variable "hcp_project" {
  description = "HCP Terraform project allowed to assume the role"
  type        = string
  default     = "Im your Huckleberry Blog Repos"
}

variable "hcp_workspace" {
  description = "HCP Terraform workspace allowed to assume the role"
  type        = string
  default     = "say_when_infra"
}