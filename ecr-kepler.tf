resource "aws_ecr_repository" "kepler_arm64" {
  name         = "kepler-arm64"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name    = "kepler-arm64"
    Purpose = "ARM64 kepler image for EKS"
  }
}