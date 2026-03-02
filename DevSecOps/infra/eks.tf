##############################
# EAST CLUSTER (always on)
##############################
module "eks_east" {
  source                         = "terraform-aws-modules/eks/aws"
  version                        = "~> 19.0"
  providers                      = { aws = aws.east }
  cluster_name                   = "say-when-east"
  cluster_version                = var.cluster_version
  vpc_id                         = module.vpc_east.vpc_id
  subnet_ids                     = module.vpc_east.public_subnets
  cluster_endpoint_public_access = true
  cluster_enabled_log_types      = []
  eks_managed_node_groups = {
    default = {
      instance_types = [var.node_instance_type]
      min_size       = var.node_min_size
      desired_size   = var.node_desired_size
      max_size       = var.node_max_size
      capacity_type  = "ON_DEMAND"
    }
  }
}
##############################
# WEST CLUSTER (optional)
##############################
module "eks_west" {
  count                          = var.enable_west ? 1 : 0
  source                         = "terraform-aws-modules/eks/aws"
  version                        = "~> 19.0"
  providers                      = { aws = aws.west }
  cluster_name                   = "say-when-west"
  cluster_version                = var.cluster_version
  vpc_id                         = module.vpc_west[0].vpc_id
  subnet_ids                     = local.vpc_west_subnets
  cluster_endpoint_public_access = true
  cluster_enabled_log_types      = []
  eks_managed_node_groups = {
    default = {
      instance_types = [var.node_instance_type]
      min_size       = var.node_min_size
      desired_size   = var.node_desired_size
      max_size       = var.node_max_size
      capacity_type  = "ON_DEMAND"
    }
  }
}