#!/usr/bin/env bash

echo "I am in CI in the innner root job script"
set -x

PLATFORM_SERVICES_FILE="${REACTORCIDE_REPOROOT}/helm_values/platform-services.yaml"
PROMETHEUS_FILE="${REACTORCIDE_REPOROOT}/helm_values/prometheus.yaml"

sed -i 's/{{cloudflareApiEmail}}/${CLOUDFLARE_API_EMAIL}/g' ${PLATFORM_SERVICES_FILE}
sed -i 's/{{cloudflareApiToken}}/${CLOUDFLARE_API_TOKEN}/g' ${PLATFORM_SERVICES_FILE}
sed -i 's/{{grafanaDatasourceCortexPassword}}/${GRAFANA_CORTEXT_PASSWORD}/g' ${PLATFORM_SERVICES_FILE}
sed -i 's/{{grafanaDatasourceLokiPassword}}/${GRAFANA_LOKI_PASSWORD}/g' ${PLATFORM_SERVICES_FILE}
sed -i 's/{{grafanaAdminPassword}}/${GRAFANA_ADMIN_PASSWORD}/g' ${PLATFORM_SERVICES_FILE}
sed -i 's/{{grafanaNotifierCatalystCommunityAlerts}}/${CATALYST_COMMUNITY_ALERTS_URL}/g' ${PLATFORM_SERVICES_FILE}
sed -i 's/{{linkerdIssuerKeyPEM}}/${LINKERD_ISSUER_KEY_PEM}/g' ${PLATFORM_SERVICES_FILE}
sed -i 's/{{promtailBasicAuthPassword}}/${PROMTAIL_PASS}/g' ${PLATFORM_SERVICES_FILE}

sed -i 's/{{clusterName}}/${CLUSTER_NAME}/g' ${PROMETHEUS_FILE}

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

# Now Helm Chart
helm upgrade --install --create-namespace --namespace kube-prometheus-stack prometheus -f ${PROMETHEUS_FILE} prometheus-community/kube-prometheus-stack --version 67.5.0

helm upgrade --install --create-namespace platform-services -f ${PLATFORM_SERVICES_FILE} catalyst-helm/platform-services --version 2.1.1
