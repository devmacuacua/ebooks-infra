#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_DIR="$SCRIPT_DIR/../docker"
BACKUP_DIR="${BACKUP_DIR:-$SCRIPT_DIR/../backups}"

mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="$BACKUP_DIR/ebooks_backup_$TIMESTAMP"
mkdir -p "$BACKUP_PATH"

DATABASES=(auth_db catalog_db commerce_db reading_db notification_db social_db media_db)

PGUSER="${POSTGRES_USER:-ebooks}"
PGPASSWORD="${POSTGRES_PASSWORD:-ebooks_secret}"
PGHOST="localhost"
PGPORT="${POSTGRES_PORT:-5432}"

export PGPASSWORD

echo "==> Starting backup at $TIMESTAMP"

for DB in "${DATABASES[@]}"; do
  echo "    Dumping $DB..."
  pg_dump -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$DB" -Fc \
    -f "$BACKUP_PATH/${DB}.dump"
  echo "    OK: $BACKUP_PATH/${DB}.dump"
done

# Compress the whole backup folder
ARCHIVE="$BACKUP_DIR/ebooks_backup_$TIMESTAMP.tar.gz"
tar -czf "$ARCHIVE" -C "$BACKUP_DIR" "ebooks_backup_$TIMESTAMP"
rm -rf "$BACKUP_PATH"

echo ""
echo "==> Backup saved: $ARCHIVE"
echo "    Size: $(du -h "$ARCHIVE" | cut -f1)"

# Keep last 7 daily backups, delete older
find "$BACKUP_DIR" -name "ebooks_backup_*.tar.gz" -mtime +7 -delete
echo "    Old backups cleaned (kept last 7 days)."

unset PGPASSWORD
