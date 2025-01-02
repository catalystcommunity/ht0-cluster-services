#!/usr/bin/env bash

echo "I am in CI in the innner root job script"
set -x

CLUSTER_SERVICES_FILE="${REACTORCIDE_REPOROOT}/helm_values/cluster-services.yaml"
PROMETHEUS_FILE="${REACTORCIDE_REPOROOT}/helm_values/prometheus.yaml"

sed -i 's/{{cloudflareApiEmail}}/${CLOUDFLARE_API_EMAIL}/g' ${CLUSTER_SERVICES_FILE}
sed -i 's/{{cloudflareApiToken}}/${CLOUDFLARE_API_TOKEN}/g' ${CLUSTER_SERVICES_FILE}
sed -i 's/{{grafanaDatasourceCortexPassword}}/${GRAFANA_CORTEXT_PASSWORD}/g' ${CLUSTER_SERVICES_FILE}
sed -i 's/{{grafanaDatasourceLokiPassword}}/${GRAFANA_LOKI_PASSWORD}/g' ${CLUSTER_SERVICES_FILE}
sed -i 's/{{grafanaAdminPassword}}/${GRAFANA_ADMIN_PASSWORD}/g' ${CLUSTER_SERVICES_FILE}
sed -i 's/{{grafanaNotifierCatalystCommunityAlerts}}/${CATALYST_COMMUNITY_ALERTS_URL}/g' ${CLUSTER_SERVICES_FILE}
sed -i 's/{{linkerdIssuerKeyPEM}}/${LINKERD_ISSUER_KEY_PEM}/g' ${CLUSTER_SERVICES_FILE}
sed -i 's/{{promtailBasicAuthPassword}}/${PROMTAIL_PASS}/g' ${CLUSTER_SERVICES_FILE}

sed -i 's/{{clusterName}}/${CLUSTER_NAME}/g' ${PROMETHEUS_FILE}

mkdir -p .kube
touch .kube/config
echo "${CI_KUBECONFIG}" > .kube/config

kubectl apply -f ${REACTORCIDE_REPOROOT}/argocd-app.yaml

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add catalyst-helm https://raw.githubusercontent.com/catalystcommunity/charts/main
helm repo update

helm upgrade --install prometheus -f ${PROMETHEUS_FILE} prometheus-community/kube-prometheus-stack --version 67.5.0

helm upgrade --install cluster-services -f ${CLUSTER_SERVICES_FILE} catalyst-helm/platform-services --version 2.1.1
