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

variable "east_azs" {
  description = "Availability Zones for the east VPC"
  type        = list(string)
}

variable "west_azs" {
  description = "Availability Zones for the west VPC"
  type        = list(string)
}

variable "east_public_subnets" {
  description = "Public subnets for the east VPC"
  type        = list(string)
}

variable "west_public_subnets" {
  description = "Public subnets for the west VPC"
  type        = list(string)
}


############################################
# EKS CONFIGURATION
############################################

variable "cluster_version" {
  description = "Kubernetes version for the EKS clusters"
  type        = string
  default     = "1.30"
}

variable "node_instance_types" {
  description = "Instance types for EKS managed node groups (SPOT fallback list)"
  type        = list(string)
  default     = ["t4g.small", "t4g.medium", "t3.small", "t3.medium"]
}

variable "node_min_size" {
  description = "Minimum number of nodes in the node group"
  type        = number
  default     = 2
}

variable "node_desired_size" {
  description = "Desired number of nodes in the node group"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of nodes in the node group"
  type        = number
  default     = 2
}

variable "bucket_name" {
  description = "Name of the Thanos S3 bucket"
  type        = string
}