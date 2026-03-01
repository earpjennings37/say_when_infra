module "vpc_east" {
  source  = "terraform-aws-modules/vpc/aws"
  providers = { aws = aws.east }
  name = "say-when-east"
  cidr = "10.0.0.0/16"
  azs  = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = false
}

module "vpc_west" {
  source  = "terraform-aws-modules/vpc/aws"
  providers = { aws = aws.west }
  name = "say-when-west"
  cidr = "10.1.0.0/16"
  azs  = ["us-west-2a", "us-west-2b"]
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24"]
  public_subnets  = ["10.1.3.0/24", "10.1.4.0/24"]

    enable_nat_gateway = false
}