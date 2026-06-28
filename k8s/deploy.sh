#!/usr/bin/env bash
# Deploy completo ou por serviço
# Uso:
#   ./deploy.sh                        — deploya tudo
#   ./deploy.sh ebooks-auth-service    — deploya apenas um serviço
#   ./deploy.sh --infra                — instala/actualiza a infra (Postgres, Redis, etc.)
#   ./deploy.sh --ingress              — aplica ingress + cert-manager

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHART="$SCRIPT_DIR/chart"
VALUES_DIR="$SCRIPT_DIR/values"
NAMESPACE="ebooks"
INFRA_NS="ebooks-infra"

SERVICES=(
  ebooks-api-gateway
  ebooks-auth-service
  ebooks-catalog-service
  ebooks-commerce-service
  ebooks-reading-service
  ebooks-notification-service
  ebooks-social-service
  ebooks-media-service
  ebooks-partner-service
  ebooks-delivery-service
  ebooks-analytics-service
  ebooks-web
)

deploy_service() {
  local svc=$1
  local values="$VALUES_DIR/${svc}.yaml"
  if [[ ! -f "$values" ]]; then
    echo "WARN: No values file for $svc, skipping."
    return
  fi
  echo "==> Deploying $svc..."
  helm upgrade --install "$svc" "$CHART" \
    --namespace "$NAMESPACE" \
    --create-namespace \
    --values "$values" \
    --wait \
    --timeout 3m
  echo "    OK: $svc"
}

deploy_infra() {
  echo "==> Installing infrastructure (Bitnami charts)..."
  helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null || true
  helm repo update

  helm upgrade --install ebooks-postgresql bitnami/postgresql \
    -f "$SCRIPT_DIR/infra/postgres-values.yaml" \
    -n "$INFRA_NS" --create-namespace --wait

  helm upgrade --install ebooks-rabbitmq bitnami/rabbitmq \
    -f "$SCRIPT_DIR/infra/rabbitmq-values.yaml" \
    -n "$INFRA_NS" --wait

  helm upgrade --install ebooks-redis bitnami/redis \
    -f "$SCRIPT_DIR/infra/redis-values.yaml" \
    -n "$INFRA_NS" --wait

  helm upgrade --install ebooks-elasticsearch bitnami/elasticsearch \
    -f "$SCRIPT_DIR/infra/elasticsearch-values.yaml" \
    -n "$INFRA_NS" --wait

  helm upgrade --install ebooks-minio bitnami/minio \
    -f "$SCRIPT_DIR/infra/minio-values.yaml" \
    -n "$INFRA_NS" --wait

  echo "==> Infra ready."
}

deploy_ingress() {
  echo "==> Applying namespace, cert-manager issuer and ingress..."
  kubectl apply -f "$SCRIPT_DIR/namespace.yaml"
  kubectl apply -f "$SCRIPT_DIR/cert-manager/cluster-issuer.yaml"
  kubectl apply -f "$SCRIPT_DIR/ingress/ingress.yaml"
  echo "==> Ingress ready."
}

# ─── Parse arguments ──────────────────────────────────────────────────────────

if [[ $# -eq 0 ]]; then
  # Deploy all services
  for svc in "${SERVICES[@]}"; do deploy_service "$svc"; done
elif [[ "$1" == "--infra" ]]; then
  deploy_infra
elif [[ "$1" == "--ingress" ]]; then
  deploy_ingress
elif [[ "$1" == "--all" ]]; then
  deploy_ingress
  deploy_infra
  for svc in "${SERVICES[@]}"; do deploy_service "$svc"; done
else
  deploy_service "$1"
fi

echo ""
echo "==> Done. Check pods: kubectl get pods -n $NAMESPACE"
