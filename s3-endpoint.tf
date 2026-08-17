data "aws_iam_policy_document" "s3_endpoint" {
  statement {
    sid    = "AllowThanosBucket"
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::thanos-infinity-37",
      "arn:aws:s3:::thanos-infinity-37/*"
    ]
  }
}

resource "aws_vpc_endpoint" "s3_east" {
  provider          = aws.east
  vpc_id            = module.vpc_east.vpc_id
  service_name      = "com.amazonaws.${var.regions.east}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = module.vpc_east.public_route_table_ids

  policy = data.aws_iam_policy_document.s3_endpoint.json

  tags = merge(
    local.tags,
    {
      Name = "${local.eks_east_name}-s3-endpoint"
    }
  )
}