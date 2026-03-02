resource "helm_release" "argocd_east" {
  provider = helm.east
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  create_namespace = true
  values = [
    file("${path.module}/argocd_values.yaml")
  ]
}

resource "helm_release" "argocd_west" {
  provider = helm.west
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  create_namespace = true
  values = [
    file("${path.module}/argocd_values.yaml")
  ]
}