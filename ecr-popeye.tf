resource "aws_ecr_repository" "popeye" {
  name                 = "popeye-arm64"
  image_tag_mutability = "MUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name    = "popeye-arm64"
    Purpose = "ARM64 Popeye image for EKS"
  }
}