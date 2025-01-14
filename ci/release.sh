#!/usr/bin/env bash

touch runnerenv.sh
echo "REACTORCIDE_JOB_REPO_URL=${REACTORCIDE_JOB_REPO_URL}" >> runnerenv.sh

touch jobenv.sh
echo "REACTORCIDE_JOB_ENTRYPOINT=${REACTORCIDE_JOB_ENTRYPOINT}" >> jobenv.sh
echo "CI_KUBECONFIG=\"${CI_KUBECONFIG}\"" >> jobenv.sh
echo "CLOUDFLARE_API_EMAIL=\"${CLOUDFLARE_API_EMAIL}\"" >> jobenv.sh
echo "CLOUDFLARE_API_TOKEN=\"${CLOUDFLARE_API_TOKEN}\"" >> jobenv.sh
echo "GRAFANA_CORTEXT_PASSWORD=\"${GRAFANA_CORTEXT_PASSWORD}\"" >> jobenv.sh
echo "GRAFANA_LOKI_PASSWORD=\"${GRAFANA_LOKI_PASSWORD}\"" >> jobenv.sh
echo "GRAFANA_ADMIN_PASSWORD=\"${GRAFANA_ADMIN_PASSWORD}\"" >> jobenv.sh
echo "CATALYST_COMMUNITY_ALERTS_URL=\"${CATALYST_COMMUNITY_ALERTS_URL}\"" >> jobenv.sh
echo "LINKERD_ISSUER_KEY_PEM=\"${LINKERD_ISSUER_KEY_PEM}\"" >> jobenv.sh
echo "PROMTAIL_PASS=\"${PROMTAIL_PASS}\"" >> jobenv.sh
echo "CLUSTER_NAME=\"${CLUSTER_NAME}\"" >> jobenv.sh
echo "METRICS_BUCKET_ACCESS_KEY_ID=\"${METRICS_BUCKET_ACCESS_KEY_ID}\"" >> jobenv.sh
echo "METRICS_BUCKET_ACCESS_KEY=\"${METRICS_BUCKET_ACCESS_KEY}\"" >> jobenv.sh

touch cisshkey
echo "${CI_SSH_KEY}" >> cisshkey
chmod 600 cisshkey
scp -i cisshkey -o "StrictHostKeyChecking=no" -P ${CI_HOST_PORT} runnerenv.sh jobenv.sh ${CI_HOST_USER}@${CI_HOST_ADDRESS}:~/
# external-root.sh should already exist per reactorcide requirements
ssh ${CI_HOST_USER}@${CI_HOST_ADDRESS} -i cisshkey -o "StrictHostKeyChecking=no" -p ${CI_HOST_PORT} ./external-root.sh
