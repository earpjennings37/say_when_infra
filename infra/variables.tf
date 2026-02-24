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