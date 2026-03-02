locals {
  # ----------------------------------------
  # West VPC subnets (safe even when disabled)
  # ----------------------------------------
  vpc_west_subnets = var.enable_west ? module.vpc_west[0].public_subnets : []

  # ----------------------------------------
  # West EKS cluster endpoint (safe)
  # ----------------------------------------
  eks_west_endpoint = var.enable_west ? module.eks_west[0].cluster_endpoint : ""

  # ----------------------------------------
  # West EKS cluster CA data (safe)
  # ----------------------------------------
  eks_west_ca = var.enable_west ? base64decode(module.eks_west[0].cluster_certificate_authority_data) : ""

  # ----------------------------------------
  # West EKS auth token (safe)
  # ----------------------------------------
  eks_west_token = var.enable_west ? data.aws_eks_cluster_auth.west[0].token : ""

  # ----------------------------------------
  # Optional: west cluster name (cleaner references)
  # ----------------------------------------
  eks_west_name = var.enable_west ? module.eks_west[0].cluster_name : ""
}

/*
locals {
  account_id = data.aws_caller_identity.current.account_id
  irsa_policies = {
    s3-backup = data.aws_iam_policy_document.s3_backup.json
  }
  ecr_repos = {
    metrics-server = {
      name                                      = "metrics-server"
      mutability                                = "MUTABLE"
      force_delete                              = true
      encryption_type                           = "KMS"
      days_untagged_image_expires               = 30
      expire_since_image_pushed_count_number    = 90
      expire_since_image_pushed_tag_prefix_list = ["metrics-server"]
      expire_since_image_pushed_count_unit      = "DAYS"
    },
    kube-prometheus-stack = {
      name                                      = "kube-prometheus-stack"
      mutability                                = "MUTABLE"
      force_delete                              = true
      encryption_type                           = "KMS"
      days_untagged_image_expires               = 30
      expire_since_image_pushed_count_number    = 90
      expire_since_image_pushed_tag_prefix_list = ["kube-prometheus-stack"]
      expire_since_image_pushed_count_unit      = "DAYS"
    },
  }
}
*/