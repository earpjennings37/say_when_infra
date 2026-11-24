############################################
# REGION CONFIGURATION
############################################

variable "regions" {
  description = "AWS regions for east and west clusters"
  type        = map(string)
}

variable "enable_west" {
  description = "Enable or disable the west region infrastructure"
  type        = bool
  default     = false
}


############################################
# VPC CONFIGURATION
############################################

variable "east_cidr" {
  description = "CIDR block for the east VPC"
  type        = string
}

variable "west_cidr" {
  description = "CIDR block for the west VPC"
  type        = string
}


############################################
# EKS CONFIGURATION
############################################

variable "cluster_version" {
  description = "Kubernetes version for the EKS clusters"
  type        = string
  default     = "1.35"
}

variable "node_instance_types" {
  description = "Instance types for the managed (system) node group, tried in order"
  type        = list(string)
  default     = ["t4g.medium", "c6g.large", "c7g.large"]
}

variable "node_min_size" {
  description = "Minimum number of nodes in the node group"
  type        = number
  default     = 2
}

variable "node_desired_size" {
  description = "Desired number of nodes in the node group"
  type        = number
  default     = 3
}

variable "node_max_size" {
  description = "Maximum number of nodes in the node group"
  type        = number
  default     = 3
}

variable "bucket_name" {
  description = "Name of the Thanos S3 bucket"
  type        = string
}

variable "node_capacity_type" {
  description = "Capacity for the managed (system) node group. ON_DEMAND keeps CoreDNS, Argo CD and the Karpenter controller up when Spot is scarce; Karpenter still adds Spot nodes for workloads."
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_capacity_type)
    error_message = "node_capacity_type must be ON_DEMAND or SPOT."
  }
}

############################################
# EKS ACCESS CONFIGURATION
############################################

variable "eks_admin_principal_arn" {
  description = "IAM Identity Center role ARN granted administrator access to the east EKS cluster"
  type        = string

  validation {
    condition = (
      startswith(var.eks_admin_principal_arn, "arn:aws:iam::") &&
      strcontains(var.eks_admin_principal_arn, ":role/")
    )

    error_message = "eks_admin_principal_arn must be a valid IAM role ARN."
  }
}