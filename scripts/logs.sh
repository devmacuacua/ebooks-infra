#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_DIR="$SCRIPT_DIR/../docker"

cd "$DOCKER_DIR"

SERVICES=(
  gateway auth catalog commerce reading notification social media web
  postgres rabbitmq redis elasticsearch minio
)

usage() {
  echo "Usage: $0 [service] [--tail N] [--follow]"
  echo ""
  echo "  service    One of: ${SERVICES[*]}"
  echo "             Leave blank to tail all services"
  echo "  --tail N   Number of lines to show (default: 100)"
  echo "  --follow   Follow log output"
  exit 1
}

SERVICE=""
TAIL=100
FOLLOW=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --tail) TAIL="$2"; shift 2 ;;
    --follow|-f) FOLLOW="--follow"; shift ;;
    --help|-h) usage ;;
    *)
      if [[ -z "$SERVICE" ]]; then
        SERVICE="ebooks-$1-service"
        # handle special infra service names
        case $1 in
          postgres)      SERVICE="ebooks-postgres" ;;
          rabbitmq)      SERVICE="ebooks-rabbitmq" ;;
          redis)         SERVICE="ebooks-redis" ;;
          elasticsearch) SERVICE="ebooks-elasticsearch" ;;
          minio)         SERVICE="ebooks-minio" ;;
          web)           SERVICE="ebooks-web" ;;
        esac
      fi
      shift
      ;;
  esac
done

docker compose -f docker-compose.yml logs --tail="$TAIL" $FOLLOW $SERVICE
