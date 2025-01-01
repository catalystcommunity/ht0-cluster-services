#!/usr/bin/env bash

echo "I am in CI in the innner root job script"
set -x

mkdir -p .kube
touch .kube/config
echo "home.todandlorna.com"
# echo "${CI_KUBECONFIG}" > .kube/config
# kubectl get pods -A

# kubectl apply ./argocd-app.yaml

# helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# helm repo add catalyst-helm https://raw.githubusercontent.com/catalystcommunity/charts/main
# helm repo update

# helm upgrade --install -f ./helm_values/prometheus.yaml prometheus-community/kube-prometheus-stack --version 67.5.0

# helm upgrade --install -f ./helm_values/cluster-services.yaml catalyst-helm/platform-services --version 2.1.1
