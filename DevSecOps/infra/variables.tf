/*
variable "service_accounts" {
  default = {
    #IRSA Role for S3 Backup
    name      = "s3-backup"
    namespace = "backup"
  }
}
*/
variable "regions" {
  type = map(string)
}

variable "enable_west" {
  type    = bool
  default = false
}

variable "cluster_version" {
  type    = string
  default = "1.30"
}

variable "node_instance_type" {
  type    = string
  default = "t4g.small"
}

variable "node_min_size" {
  type    = number
  default = 0
}
variable "node_desired_size" {
  type    = number
  default = 0
}
variable "node_max_size" {
  type    = number
  default = 1
}
variable "east_azs" {
  type = list(string)
}
variable "west_azs" {
  type = list(string)
}
variable "east_cidr" {
  type = string
}
variable "west_cidr" {
  type = string
}