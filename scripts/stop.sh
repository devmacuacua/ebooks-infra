#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_DIR="$SCRIPT_DIR/../docker"

cd "$DOCKER_DIR"

usage() {
  echo "Usage: $0 [--with-observability] [--volumes]"
  echo ""
  echo "  --with-observability  Also stop Prometheus/Grafana/Loki"
  echo "  --volumes             Remove volumes (WARNING: destroys all data)"
  exit 1
}

WITH_OBS=false
VOLUMES_FLAG=""

for arg in "$@"; do
  case $arg in
    --with-observability) WITH_OBS=true ;;
    --volumes)
      echo "WARNING: --volumes will destroy all database data. Are you sure? [y/N]"
      read -r confirm
      if [[ "$confirm" =~ ^[Yy]$ ]]; then
        VOLUMES_FLAG="-v"
      else
        echo "Aborted."
        exit 0
      fi
      ;;
    --help|-h) usage ;;
    *) echo "Unknown argument: $arg"; usage ;;
  esac
done

COMPOSE_FILES="-f docker-compose.yml"
if [ "$WITH_OBS" = true ]; then
  COMPOSE_FILES="$COMPOSE_FILES -f docker-compose.observability.yml"
fi

echo "==> Stopping ebooks platform..."
docker compose $COMPOSE_FILES down $VOLUMES_FLAG

echo "==> Done."
