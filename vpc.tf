module "vpc_east" {
  source    = "terraform-aws-modules/vpc/aws"
  version   = "~> 5.0"
  name      = "say-when-east"
  providers = { aws = aws.east }

  cidr      = var.east_cidr

  azs = [
    "${var.regions.east}a",
    "${var.regions.east}b"
  ]

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  enable_nat_gateway      = false
  single_nat_gateway      = false

  enable_dns_hostnames    = true
  enable_dns_support      = true
  map_public_ip_on_launch = true
}

# ⭐ FREE outbound internet for EAST
resource "aws_route" "east_public_internet_access_1" {
  route_table_id         = module.vpc_east.public_route_table_ids[0]
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc_east.igw_id
}

resource "aws_route" "east_public_internet_access_2" {
  route_table_id         = module.vpc_east.public_route_table_ids[1]
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc_east.igw_id
}

module "vpc_west" {
  count     = var.enable_west ? 1 : 0
  source    = "terraform-aws-modules/vpc/aws"
  version   = "~> 5.0"
  name      = "say-when-west"
  providers = { aws = aws.west }

  cidr      = var.west_cidr

  azs = [
    "${var.regions.west}a",
    "${var.regions.west}b"
  ]

  public_subnets = [
    "10.1.1.0/24",
    "10.1.2.0/24"
  ]

  enable_nat_gateway      = false
  single_nat_gateway      = false

  enable_dns_hostnames    = true
  enable_dns_support      = true
  map_public_ip_on_launch = true
}

# ⭐ FREE outbound internet for WEST (only created if west is enabled)
resource "aws_route" "west_public_internet_access_1" {
  count                  = var.enable_west ? 1 : 0
  route_table_id         = module.vpc_west[0].public_route_table_ids[0]
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc_west[0].igw_id
}

resource "aws_route" "west_public_internet_access_2" {
  count                  = var.enable_west ? 1 : 0
  route_table_id         = module.vpc_west[0].public_route_table_ids[1]
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc_west[0].igw_id
}
