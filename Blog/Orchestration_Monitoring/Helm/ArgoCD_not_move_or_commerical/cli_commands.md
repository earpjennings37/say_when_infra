# Commands & Steps to Add ArgoCD

# Install ArgoCD
- brew install argocd
- kubectl port-forward svc/argocd-server -n argocd 8080:443
- argocd login 127.0.0.1:8080
- kubectl create namespace argocd
- kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# Port-Foward Options
Option 1: from kubectl 
- port-foward service/argocd-server -n argocd 8080:443
Option 2: from k9s 
- port-forward argocd-server to 8080
# Login to Argocd Options
Option 1 to get secret password: from kubectl
- kubectl create namespace argocd
- kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
Option 2 to get secret password: from k9s
- type :secrets
- hit x on the preferred option you desire
- initial admin secret is the login to argocd
- secret is the RSA private keys
# Review ArgoCD of your Helm Chart install & view in k9s
Check around the features of ArgoCD & how they match in real time k9s
# Experiment 1: Scale Replicas
- Either in github repo or k9s change the pods replica
- Watch in ArgoCD the alteration
# Expiriment 2: Roll-Back
- Navigate in ArgoCD to rollback your version deployment
- Check in k9s once again the instantaneous rollback in ArgoCD of your scaled pods.