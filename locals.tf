locals {
  ############################################
  # REGION SHORTCUTS
  ############################################
  region_east = var.regions.east
  region_west = var.regions.west

  ############################################
  # CLUSTER NAMES
  ############################################
  eks_east_name = "say-when-east"
  eks_west_name = var.enable_west ? "say-when-west" : null

  ############################################
  # TAGS
  ############################################
  tags = {
    project     = "say-when"
    environment = "dev"
  }
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