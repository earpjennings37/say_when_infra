module "vpc_east" {
  source    = "terraform-aws-modules/vpc/aws"
  version   = "~> 5.0"
  name      = "say-when-east"
  providers = { aws = aws.east }
  cidr      = var.east_cidr
  # Two AZs required for EKS control plane
  azs = [
    "${var.regions.east}a",
    "${var.regions.east}b"
  ]
  # Two public subnets (still no private subnets, no NAT)
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
module "vpc_west" {
  count     = var.enable_west ? 1 : 0
  source    = "terraform-aws-modules/vpc/aws"
  version   = "~> 5.0"
  name      = "say-when-west"
  providers = { aws = aws.west }
  cidr      = var.west_cidr
  # Two AZs required for EKS control plane
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
