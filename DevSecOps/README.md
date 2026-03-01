#
# Includes code organized into various DevSecOps Tooling for the Cloud. 
#

My thought of this repo was to provisions AWS infra using Terraform & deploys Kubernetes applications using Argo CD and GitOps in us-east-1 & us-east-2. From here was to have Terraform build the AWS infra + EKS & install ArgoCD. From here ArgoCD deploys various tooling apps using the upstream Helm Charts values. However...we'll see if this changes!?

Take a peak at stuff in here & see what you think as i mess w/following:
- Helm Charts
- Kubernetes
- ArgoCD
- Terraform
- AWS
- Prometheus/Loki/Grafana