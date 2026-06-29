#!/usr/bin/env bash
# =============================================================================
# seed.sh — Popula as bases de dados com dados fictícios para dev/testes
#
# Uso:
#   ./seed.sh              # seed (idempotente — seguro re-executar)
#   ./seed.sh --reset      # apaga TODOS os dados e re-faz o seed
#
# Pré-requisito: stack em execução (docker compose up -d)
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_DIR="$(cd "$SCRIPT_DIR/../docker" && pwd)"

PG_USER="${POSTGRES_USER:-ebooks}"
PG_PASS="${POSTGRES_PASSWORD:-ebooks_secret}"
PG_HOST="${POSTGRES_HOST:-localhost}"
PG_PORT="${POSTGRES_PORT:-5432}"

PSQL="docker compose -f $DOCKER_DIR/docker-compose.yml exec -T postgres psql -U $PG_USER"

echo "🌱  EBooksStore — Seed de dados de desenvolvimento"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── Reset opcional ───────────────────────────────────────────────────────────
if [[ "${1:-}" == "--reset" ]]; then
  echo "⚠️  Reset: a apagar todos os dados de seed..."

  $PSQL auth_db <<'SQL'
DELETE FROM refresh_tokens;
DELETE FROM email_verifications;
DELETE FROM oauth_accounts;
DELETE FROM users WHERE id IN (
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000003',
  '00000000-0000-0000-0000-000000000004',
  '00000000-0000-0000-0000-000000000005'
);
SQL

  $PSQL catalog_db <<'SQL'
DELETE FROM reviews WHERE user_id IN (
  '00000000-0000-0000-0000-000000000002',
  '00000000-0000-0000-0000-000000000003',
  '00000000-0000-0000-0000-000000000004'
);
DELETE FROM book_categories WHERE book_id LIKE 'b0000000%';
DELETE FROM book_authors   WHERE book_id LIKE 'b0000000%';
DELETE FROM books WHERE id LIKE 'b0000000%';
DELETE FROM tags       WHERE id LIKE 't0000000%';
DELETE FROM categories WHERE id LIKE 'c0000000%';
DELETE FROM authors    WHERE id LIKE 'a0000000%';
SQL

  $PSQL commerce_db <<'SQL'
DELETE FROM order_items WHERE order_id IN (
  'ord00000-0000-0000-0000-000000000001',
  'ord00000-0000-0000-0000-000000000002'
);
DELETE FROM orders WHERE id LIKE 'ord00000%';
DELETE FROM addresses WHERE id LIKE 'addr0000%';
DELETE FROM subscriptions WHERE id LIKE 'sub00000%';
DELETE FROM subscription_plans WHERE id LIKE 'sp000000%';
SQL

  $PSQL partner_db <<'SQL'
DELETE FROM "Partner" WHERE id = 'pt000000-0000-0000-0000-000000000001';
SQL

  echo "✓  Dados anteriores removidos."
  echo ""
fi

# ── Seed principal ───────────────────────────────────────────────────────────
echo "📥  A inserir dados em auth_db, catalog_db e commerce_db..."
$PSQL -f /dev/stdin < "$SCRIPT_DIR/seed.sql"
echo "✓  seed.sql aplicado."

echo "📥  A inserir parceiro em partner_db..."
$PSQL -f /dev/stdin < "$SCRIPT_DIR/seed-partner.sql"
echo "✓  seed-partner.sql aplicado."

# ── Resumo ───────────────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅  Seed concluído! Contas de teste:"
echo ""
echo "  👤 admin@ebooks.co.mz        / Admin@1234  (ADMIN)"
echo "  👤 francisco@ebooks.co.mz    / Test@1234   (cliente com subscrição activa)"
echo "  👤 maria@ebooks.co.mz        / Test@1234   (cliente com encomenda)"
echo "  👤 joao@ebooks.co.mz         / Test@1234   (cliente)"
echo "  👤 editora@ndzidzi.co.mz     / Test@1234   (parceiro ACTIVE)"
echo ""
echo "  📚 7 livros PUBLISHED · 1 PENDING_REVIEW · 1 REJECTED"
echo "  📦 2 encomendas · 1 subscrição activa · 1 parceiro"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
