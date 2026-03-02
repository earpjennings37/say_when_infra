module "vpc_east" {
  source               = "terraform-aws-modules/vpc/aws"
  providers            = { aws = aws.east }
  name                 = "say-when-east"
  cidr                 = "10.0.0.0/16"
  azs                  = ["us-east-1a", "us-east-1b"]
  public_subnets       = ["10.0.1.0/24", "10.0.2.0/24"]
  enable_nat_gateway   = false
  single_nat_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true
}

module "vpc_west" {
  count                = var.enable_west ? 1 : 0
  source               = "terraform-aws-modules/vpc/aws"
  providers            = { aws = aws.west }
  name                 = "say-when-west"
  cidr                 = "10.1.0.0/16"
  azs                  = ["us-west-2a", "us-west-2b"]
  public_subnets       = ["10.1.1.0/24", "10.1.2.0/24"]
  enable_nat_gateway   = false
  single_nat_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true
}
