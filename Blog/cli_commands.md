# Below are commands to run if you desire seeing metrics-server in your k9s

# 1st Command
kubectl create namespace metrics
# 2nd Command
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
# 3rd Command
helm repo update
# 4th Command
$ helm upgrade --install metrics-server metrics-server/metrics-server \
  --namespace metrics \
  --set args={--kubelet-insecure-tls}