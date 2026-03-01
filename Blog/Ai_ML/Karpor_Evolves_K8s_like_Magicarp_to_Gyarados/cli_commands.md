# Below are steps to EVOLVE your k8s w/Karpor

# Install Kusionstack Karpor CLI
- brew tap KusionStack/tap
- brew install KusionStack/tap/kusion
# Helm Repo Add Karpor
- helm repo add kusionstack https://kusionstack.github.io/charts
- helm repo update
- helm install karpor kusionstack/karpor
# Go to K9s
- Type :NamespaceNavigate to karpor namespaces, go to karpor
- Port-Forward to 7443