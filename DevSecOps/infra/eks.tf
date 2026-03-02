module "eks_east" {
  source  = "terraform-aws-modules/eks/aws"
  providers = { aws = aws.east }
  cluster_name    = "say-when-east"
  cluster_version = var.cluster_version
  vpc_id     = module.vpc_east.vpc_id
  subnet_ids = module.vpc_east.public_subnets
  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.small"]
      desired_size   = 1
      min_size       = 1
      max_size       = 1
    }
  }
}

module "eks_west" {
  count = var.enable_west ? 1 : 0
  source  = "terraform-aws-modules/eks/aws"
  providers = { aws = aws.west }
  cluster_name    = "say-when-west"
  cluster_version = var.cluster_version
  vpc_id     = module.vpc_west[0].vpc_id
  subnet_ids = module.vpc_west[0].public_subnets
  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.small"]
      desired_size   = 1
      min_size       = 1
      max_size       = 1
    }
  }
}