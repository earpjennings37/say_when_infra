terraform {
  required_version = "= 1.14.5"

  backend "s3" {
    bucket       = "earp-tf-state-37"
    key          = "global/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.30.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}