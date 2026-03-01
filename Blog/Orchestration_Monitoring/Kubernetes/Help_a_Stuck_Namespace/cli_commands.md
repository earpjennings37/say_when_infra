# Below are troubleshooting steps if you deleted a namespace.. but it still is lingering..

# Leverage this resource
https://www.redhat.com/en/blog/troubleshooting-terminating-namespaces

# Open 2 terminals:
- Terminal 1
minikube start
minikube dashboard --url
- Terminal 2
- kubectl get namespace k8sgpt
- operator-system -o json > tmp.json
- vi tmp.json
- curl -k -H "Content-Type: application/json" -X PUT --data-binary @tmp.json http://127.0.0.1:38717/api/v1/namespaces/k8spt-operator-system/finalize