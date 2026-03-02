/*
module "eks_east" {
  source  = "terraform-aws-modules/eks/aws"
  providers = { aws = aws }
  cluster_name    = "say-when-east"
  cluster_version = var.cluster_version
  vpc_id     = module.vpc_east.vpc_id
  subnet_ids = module.vpc_east.private_subnets
  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"]
      desired_size   = 2
    }
  }
}

module "eks_west" {
  source  = "terraform-aws-modules/eks/aws"
  providers = { aws = aws.west }
  cluster_name    = "say-when-west"
  cluster_version = var.cluster_version
  vpc_id     = module.vpc_west.vpc_id
  subnet_ids = module.vpc_west.private_subnets
  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"]
      desired_size   = 2
    }
  }
}
*/