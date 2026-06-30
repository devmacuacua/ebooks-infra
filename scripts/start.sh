#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_DIR="$SCRIPT_DIR/../docker"

cd "$DOCKER_DIR"

usage() {
  echo "Usage: $0 [--with-observability] [--build]"
  echo ""
  echo "  --with-observability  Also start Prometheus, Grafana, Loki stack"
  echo "  --build               Rebuild images before starting"
  exit 1
}

WITH_OBS=false
BUILD_FLAG=""

for arg in "$@"; do
  case $arg in
    --with-observability) WITH_OBS=true ;;
    --build) BUILD_FLAG="--build" ;;
    --help|-h) usage ;;
    *) echo "Unknown argument: $arg"; usage ;;
  esac
done

COMPOSE_FILES="-f docker-compose.yml"
if [ "$WITH_OBS" = true ]; then
  COMPOSE_FILES="$COMPOSE_FILES -f docker-compose.observability.yml"
fi

# Remove containers antigos que possam conflituar (de runs anteriores sem project name, etc.)
echo "==> Cleaning up old containers..."
docker compose $COMPOSE_FILES down --remove-orphans 2>/dev/null || true
# Força remoção de containers ebooks-* que possam ter ficado pendurados
docker ps -a --filter "name=ebooks-" --format "{{.Names}}" \
  | xargs -r docker rm -f 2>/dev/null || true

echo "==> Starting ebooks platform..."
docker compose $COMPOSE_FILES up -d $BUILD_FLAG

echo ""
echo "==> Services:"
docker compose $COMPOSE_FILES ps

echo ""
echo "==> Platform is up."
echo "    Frontend:  http://localhost:3000"
echo "    Gateway:   http://localhost:8080"
if [ "$WITH_OBS" = true ]; then
  echo "    Grafana:   http://localhost:3100  (admin / ebooks_grafana)"
  echo "    Prometheus:http://localhost:9090"
fi
