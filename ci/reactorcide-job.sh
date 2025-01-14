#!/usr/bin/env bash

echo "I am in CI in the innner root job script"

export PLATFORM_SERVICES_TEMPLATE="${REACTORCIDE_REPOROOT}/helm_values/platform-services.yaml"
export PLATFORM_SERVICES_FILE="${REACTORCIDE_REPOROOT}/helm_values/ciresult_platform-services.yaml"
export PROMETHEUS_TEMPLATE="${REACTORCIDE_REPOROOT}/helm_values/prometheus.yaml"
export PROMETHEUS_FILE="${REACTORCIDE_REPOROOT}/helm_values/ciresult_prometheus.yaml"

mkdir -p .kube
touch .kube/config
echo "${CI_KUBECONFIG}" > .kube/config

kubectl apply -f ${REACTORCIDE_REPOROOT}/argocd-app.yaml

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add catalyst-helm https://raw.githubusercontent.com/catalystcommunity/charts/main
helm repo update

# Install CRDs first
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.2/cert-manager.crds.yaml
kubectl apply -f https://raw.githubusercontent.com/projectcontour/contour/v1.30.1/examples/contour/01-crds.yaml

curl -LsSf https://astral.sh/uv/0.5.14/install.sh | sh
uv venv
uv pip install pyyaml
uv run python ${REACTORCIDE_REPOROOT}/ci/ci_replacements.py

# Now Helm Chart
helm upgrade --install --create-namespace --namespace kube-prometheus-stack prometheus -f ${PROMETHEUS_FILE} prometheus-community/kube-prometheus-stack --version 67.5.0

helm upgrade --install --create-namespace platform-services -f ${PLATFORM_SERVICES_FILE} catalyst-helm/platform-services --version 2.3.0
