variable "service_accounts" {
  default = {
    #IRSA Role for S3 Backup
    name      = "s3-backup"
    namespace = "backup"
  }
}
variable "cluster_name" {
  type = string
}
variable "regions" {
  type = map(string)
  default = {
    "east" = "us-east-1"
    "west" = "us-west-2"
  }
}
variable "cluster_version" {
  type    = string
  default = "1.30"
}
variable "enable_west" {
  type    = bool
  default = false
}