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
##################
# POPEYE
##################

output "popeye_ecr_repository_url" {
  value = aws_ecr_repository.popeye.repository_url
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

##################
# K8sGPT
##################
output "k8sgpt_bedrock_role_arn" {
  description = "IRSA role used by the K8sGPT Bedrock workload"
  value       = aws_iam_role.k8sgpt_irsa.arn
}

##################
# External Secrets
##################
output "external_secrets_role_arn" {
  description = "IAM role used by External Secrets Operator through EKS Pod Identity"
  value       = aws_iam_role.external_secrets.arn
}

output "demo_secrets_manager_secret_name" {
  description = "Name of the temporary demo secret in AWS Secrets Manager"
  value       = aws_secretsmanager_secret.demo_app.name
}

# ============================================================
# Karpenter
# ============================================================

output "karpenter_controller_role_arn" {
  description = "IAM role assumed by the Karpenter controller through EKS Pod Identity"
  value       = module.karpenter_east.iam_role_arn
}

output "karpenter_node_role_arn" {
  description = "Existing EKS managed node role reused by Karpenter nodes"
  value       = module.karpenter_east.node_iam_role_arn
}

output "karpenter_node_instance_profile_name" {
  description = "Stable IAM instance profile used by Karpenter EC2 nodes"
  value       = aws_iam_instance_profile.karpenter_nodes.name
}

output "karpenter_interruption_queue_name" {
  description = "SQS queue consumed by Karpenter for interruption events"
  value       = module.karpenter_east.queue_name
}