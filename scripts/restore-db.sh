#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <backup-archive.tar.gz> [database]"
  echo ""
  echo "  backup-archive.tar.gz   Path to backup archive created by backup-db.sh"
  echo "  database                Restore only this DB (e.g. catalog_db). Leave blank for all."
  exit 1
}

[[ $# -lt 1 ]] && usage

ARCHIVE="$1"
TARGET_DB="${2:-}"

[[ ! -f "$ARCHIVE" ]] && { echo "ERROR: File not found: $ARCHIVE"; exit 1; }

PGUSER="${POSTGRES_USER:-ebooks}"
PGPASSWORD="${POSTGRES_PASSWORD:-ebooks_secret}"
PGHOST="localhost"
PGPORT="${POSTGRES_PORT:-5432}"

export PGPASSWORD

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "==> Extracting $ARCHIVE..."
tar -xzf "$ARCHIVE" -C "$TMPDIR"

BACKUP_DIR=$(find "$TMPDIR" -maxdepth 1 -type d | tail -1)

DATABASES=(auth_db catalog_db commerce_db reading_db notification_db social_db media_db)

echo "WARNING: This will overwrite data in the target database(s). Continue? [y/N]"
read -r confirm
[[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }

for DB in "${DATABASES[@]}"; do
  [[ -n "$TARGET_DB" && "$DB" != "$TARGET_DB" ]] && continue

  DUMP="$BACKUP_DIR/${DB}.dump"
  [[ ! -f "$DUMP" ]] && { echo "WARN: $DUMP not found, skipping."; continue; }

  echo "==> Restoring $DB..."
  pg_restore -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$DB" \
    --clean --if-exists -Fc "$DUMP"
  echo "    OK: $DB restored."
done

unset PGPASSWORD
echo ""
echo "==> Restore complete."
