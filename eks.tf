##############################
# EAST CLUSTER (always on)
##############################
module "eks_east" {
  source                         = "terraform-aws-modules/eks/aws"
  version                        = "~> 19.0"
  providers                      = { aws = aws.east }
  cluster_name                   = local.eks_east_name
  cluster_version                = var.cluster_version
  vpc_id                         = module.vpc_east.vpc_id
  subnet_ids                     = module.vpc_east.public_subnets
  cluster_endpoint_public_access = true
  cluster_enabled_log_types      = []

  enable_irsa = true

  eks_managed_node_groups = {
    prefix = {
      instance_types = var.node_instance_types
      ami_type       = "AL2023_ARM_64_STANDARD"
      min_size       = var.node_min_size
      desired_size   = var.node_desired_size
      max_size       = var.node_max_size
      capacity_type  = "SPOT"

      tags = merge(
        local.tags,
        { prefix_delegation = "true" }
      )
    }
  }

  tags = local.tags
}
##############################
# WEST CLUSTER (optional)
##############################
module "eks_west" {
  count                          = var.enable_west ? 1 : 0
  source                         = "terraform-aws-modules/eks/aws"
  version                        = "~> 19.0"
  providers                      = { aws = aws.west }
  cluster_name                   = local.eks_west_name
  cluster_version                = var.cluster_version
  vpc_id                         = module.vpc_west[0].vpc_id
  subnet_ids                     = module.vpc_west[0].public_subnets
  cluster_endpoint_public_access = true
  cluster_enabled_log_types      = []
  eks_managed_node_groups = {
    default = {
      instance_types = var.node_instance_types
      # REQUIRED for ARM (t4g.*)
      ami_type      = "AL2023_ARM_64_STANDARD"
      min_size      = var.node_min_size
      desired_size  = var.node_desired_size
      max_size      = var.node_max_size
      capacity_type = "SPOT"
      tags          = local.tags
    }
  }
  tags = local.tags
}