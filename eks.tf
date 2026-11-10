##############################
# EAST CLUSTER (always on)
##############################

module "eks_east" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.37.2"

  providers = {
    aws = aws.east
  }

  cluster_name                   = local.eks_east_name
  cluster_version                = var.cluster_version
  vpc_id                         = module.vpc_east.vpc_id
  subnet_ids                     = module.vpc_east.public_subnets
  cluster_endpoint_public_access = true
  cluster_enabled_log_types      = []

  enable_irsa = true

  # Enable EKS Cluster Access Management while preserving
  # compatibility with the existing aws-auth ConfigMap.
  authentication_mode = "API_AND_CONFIG_MAP"

  # Do not create another cluster-creator access entry.
  # Access is granted explicitly to the IAM Identity Center
  # administrator role below.
  enable_cluster_creator_admin_permissions = false

  # Grant the IAM Identity Center administrator role
  # cluster-wide Kubernetes administrator access.
  access_entries = {
    identity_center_admin = {
      principal_arn = var.eks_admin_principal_arn

      policy_associations = {
        cluster_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  # Allow Karpenter to discover the node security group.
  node_security_group_tags = {
    "karpenter.sh/discovery" = local.eks_east_name
  }

  cluster_addons = {
    vpc-cni = {
      most_recent    = true
      before_compute = true

      configuration_values = jsonencode({
        enableNetworkPolicy = "true"

        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  }

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
        {
          prefix_delegation = "true"
        }
      )
    }
  }

  tags = local.tags
}


##############################
# WEST CLUSTER (optional)
##############################

module "eks_west" {
  count   = var.enable_west ? 1 : 0
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  providers = {
    aws = aws.west
  }

  cluster_name                   = local.eks_west_name
  cluster_version                = var.cluster_version
  vpc_id                         = module.vpc_west[0].vpc_id
  subnet_ids                     = module.vpc_west[0].public_subnets
  cluster_endpoint_public_access = true
  cluster_enabled_log_types      = []

  eks_managed_node_groups = {
    default = {
      instance_types = var.node_instance_types

      # Required for ARM-based t4g, c6g and c7g instances.
      ami_type      = "AL2023_ARM_64_STANDARD"
      min_size      = var.node_min_size
      desired_size  = var.node_desired_size
      max_size      = var.node_max_size
      capacity_type = "SPOT"

      tags = local.tags
    }
  }

  tags = local.tags
}