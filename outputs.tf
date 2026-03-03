output "cluster_name" {
  value = module.eks_east.cluster_name
}
output "eks_west_cluster_name" {
  value = var.enable_west ? module.eks_west[0].cluster_name : null
}
output "node_desired_size" {
  value = var.node_desired_size
}