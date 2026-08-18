resource "aws_vpc_endpoint" "s3_east" {
  provider          = aws.east
  vpc_id            = module.vpc_east.vpc_id
  service_name      = "com.amazonaws.${var.regions.east}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = module.vpc_east.public_route_table_ids

  tags = merge(
    local.tags,
    {
      Name = "${local.eks_east_name}-s3-endpoint"
    }
  )
}

resource "aws_vpc_endpoint_policy" "s3_east" {
  vpc_endpoint_id = aws_vpc_endpoint.s3_east.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "*"
        Resource  = "*"
      }
    ]
  })
}