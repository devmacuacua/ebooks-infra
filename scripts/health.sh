#!/usr/bin/env bash
# Quick health check for all services

SERVICES=(
  "Gateway:http://localhost:8080/actuator/health"
  "Auth:http://localhost:8081/actuator/health"
  "Catalog:http://localhost:8082/actuator/health"
  "Commerce:http://localhost:8083/actuator/health"
  "Reading:http://localhost:3001/health"
  "Notification:http://localhost:3002/health"
  "Social:http://localhost:3003/health"
  "Media:http://localhost:3004/health"
  "Web:http://localhost:3000/api/health"
)

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "==> ebooks.co.mz — Service Health Check"
echo "    $(date)"
echo ""

ALL_OK=true

for entry in "${SERVICES[@]}"; do
  NAME="${entry%%:*}"
  URL="${entry#*:}"

  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$URL" 2>/dev/null || echo "000")

  if [[ "$HTTP_CODE" == "200" ]]; then
    printf "    ${GREEN}✓${NC} %-20s %s\n" "$NAME" "$URL"
  elif [[ "$HTTP_CODE" == "000" ]]; then
    printf "    ${RED}✗${NC} %-20s unreachable\n" "$NAME"
    ALL_OK=false
  else
    printf "    ${YELLOW}?${NC} %-20s HTTP $HTTP_CODE\n" "$NAME"
    ALL_OK=false
  fi
done

echo ""

if $ALL_OK; then
  echo -e "    ${GREEN}All services are healthy.${NC}"
  exit 0
else
  echo -e "    ${RED}Some services are not responding correctly.${NC}"
  exit 1
fi
