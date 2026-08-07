#########################
# CLUSTER INFORMATION
#########################
output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks_east.cluster_name
}
output "cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = module.eks_east.cluster_endpoint
}
output "cluster_oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  value       = module.eks_east.oidc_provider_arn
}
/*
###################
# KUBECONFIG
###################
output "kubeconfig" {
  description = "Raw kubeconfig for connecting to the cluster"
  value       = module.eks_east.kubeconfig
  sensitive   = true
}
*/

###########
# ARGOCD
###########
output "argocd_server_service" {
  description = "Internal DNS name for the Argo CD API server"
  value       = "argocd-server.argocd.svc.cluster.local"
}
##################
# OBSERVABILITY
##################
output "grafana_service" {
  description = "Internal DNS name for Grafana"
  value       = "kube-prometheus-stack-grafana.monitoring.svc.cluster.local"
}

/*
#########################
# CLUSTER INFORMATION
#########################
output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks_east.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = module.eks_east.cluster_endpoint
}

output "cluster_version" {
  description = "Kubernetes version running on the cluster"
  value       = module.eks_east.cluster_version
}

output "cluster_oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  value       = module.eks_east.oidc_provider_arn
}
###################
# AUTHENTICATION
###################
output "cluster_certificate_authority" {
  description = "Base64 encoded certificate authority data"
  value       = module.eks_east.cluster_certificate_authority_data
  sensitive   = true
}
output "kubeconfig" {
  description = "Raw kubeconfig for connecting to the cluster"
  value       = module.eks_east.kubeconfig
  sensitive   = true
}
######################
# NODE GROUP DETAILS
######################
output "node_group_role_arn" {
  description = "IAM role ARN for the primary node group"
  value       = module.eks_east.node_groups["default"].iam_role_arn
}
###############
# NETWORKING
###############
output "vpc_id" {
  description = "VPC ID for the EKS cluster"
  value       = module.vpc.vpc_id
}
###########
# ARGOCD
###########
output "argocd_server_service" {
  description = "Internal DNS name for the Argo CD API server"
  value       = "argocd-server.argocd.svc.cluster.local"
}
##################
# OBSERVABILITY
##################
output "grafana_service" {
  description = "Internal DNS name for Grafana"
  value       = "kube-prometheus-stack-grafana.monitoring.svc.cluster.local"
}

output "prometheus_service" {
  description = "Internal DNS name for Prometheus"
  value       = "kube-prometheus-stack-prometheus.monitoring.svc.cluster.local"
}

output "loki_service" {
  description = "Internal DNS name for Loki"
  value       = "loki.monitoring.svc.cluster.local"
}

output "tempo_service" {
  description = "Internal DNS name for Tempo"
  value       = "tempo.monitoring.svc.cluster.local"
}
*/