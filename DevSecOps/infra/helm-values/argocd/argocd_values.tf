########################################
# Argo CD - EAST (always installed)
########################################
resource "helm_release" "argocd_east" {
  provider = helm.east
  name       = "argocd"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "6.7.12"
  create_namespace = true
  values = [
    file("${path.module}/helm-charts/argocd/values.yaml")
  ]
}
########################################
# Argo CD - WEST (installed only when enabled)
########################################
resource "helm_release" "argocd_west" {
  provider = helm.west
  count = var.enable_west ? 1 : 0
  name       = "argocd"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "6.7.12"
  create_namespace = true
  values = [
    file("${path.module}/helm-charts/argocd/values.yaml")
  ]
}