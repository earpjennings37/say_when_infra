module "vpc_east" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "~> 5.0"
  providers            = { aws = aws.east }
  name                 = "say-when-east"
  cidr                 = var.east_cidr
  azs                  = var.east_azs
  public_subnets       = ["10.0.1.0/24"]
  enable_nat_gateway   = false
  single_nat_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true
}
module "vpc_west" {
  count                = var.enable_west ? 1 : 0
  source               = "terraform-aws-modules/vpc/aws"
  version              = "~> 5.0"
  name                 = "say-when-west"
  providers            = { aws = aws.west }
  cidr                 = var.west_cidr
  azs                  = var.west_azs
  public_subnets       = ["10.1.1.0/24"]
  enable_nat_gateway   = false
  single_nat_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true
}
