#!/usr/bin/env bash
set -e

echo "=== Nodes ==="
kubectl get nodes

echo
echo "=== Argo CD ==="
kubectl get pods -n argocd

echo
echo "=== Applications ==="
kubectl get applications -n argocd

echo
echo "=== Monitoring ==="
kubectl get pods -n monitoring

echo
echo "=== PVCs ==="
kubectl get pvc -n monitoring

echo
echo "=== Node Usage ==="
kubectl top nodes

chmod +x scripts/verify-cluster.sh
./scripts/verify-cluster.sh