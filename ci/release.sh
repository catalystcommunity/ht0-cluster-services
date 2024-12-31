#!/usr/bin/env bash

set -x
CLUSTER_SERVICES_FILE="./helm_values/cluster-services.yaml"
PROMETHEUS_FILE="./helm_values/prometheus.yaml"

sed -i 's/{{cloudflareApiEmail}}/${CLOUDFLARE_API_EMAIL}/g' ${CLUSTER_SERVICES_FILE}
sed -i 's/{{cloudflareApiToken}}/${CLOUDFLARE_API_TOKEN}/g' ${CLUSTER_SERVICES_FILE}
sed -i 's/{{grafanaDatasourceCortexPassword}}/${GRAFANA_CORTEXT_PASSWORD}/g' ${CLUSTER_SERVICES_FILE}
sed -i 's/{{grafanaDatasourceLokiPassword}}/${GRAFANA_LOKI_PASSWORD}/g' ${CLUSTER_SERVICES_FILE}
sed -i 's/{{grafanaAdminPassword}}/${GRAFANA_ADMIN_PASSWORD}/g' ${CLUSTER_SERVICES_FILE}
sed -i 's/{{grafanaNotifierCatalystCommunityAlerts}}/${CATALYST_COMMUNITY_ALERTS_URL}/g' ${CLUSTER_SERVICES_FILE}
sed -i 's/{{linkerdIssuerKeyPEM}}/${LINKERD_ISSUER_KEY_PEM}/g' ${CLUSTER_SERVICES_FILE}
sed -i 's/{{promtailBasicAuthPassword}}/${PROMTAIL_PASS}/g' ${CLUSTER_SERVICES_FILE}

sed -i 's/{{clusterName}}/${CLUSTER_NAME}/g' ${PROMETHEUS_FILE}

touch runnerenv.sh
echo "REACTORCIDE_JOB_REPO_URL=${REACTORCIDE_JOB_REPO_URL}" >> runnerenv.sh

touch jobenv.sh
echo "REACTORCIDE_JOB_ENTRYPOINT=${REACTORCIDE_JOB_ENTRYPOINT}" >> jobenv.sh

touch sshkey
chmod 600 sshkey
echo "${CI_SSH_KEY}" >> sshkey
scp -i sshkey -P ${CI_HOST_PORT} runnerenv.sh jobenv.sh ${CI_HOST_ADDRESS}
ssh ${CI_HOST_ADDRESS} -i sshkey -p ${CI_HOST_PORT} external-root.sh
