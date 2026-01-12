#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$PROJECT_DIR/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_SUBDIR="$BACKUP_DIR/$TIMESTAMP"

# Load environment variables
if [ -f "$PROJECT_DIR/.env" ]; then
  source "$PROJECT_DIR/.env"
fi

POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-postgres}"

# Databases to backup
DATABASES=("smimekeys_client" "policy" "idagent" "mxengine")

echo "============================================"
echo "  PostgreSQL Backup"
echo "============================================"
echo ""
echo "Timestamp: $TIMESTAMP"
echo "Backup directory: $BACKUP_SUBDIR"
echo ""

# Check if postgres container is running
if ! docker ps --format '{{.Names}}' | grep -q "stargate-postgres"; then
  echo "ERROR: stargate-postgres container is not running."
  echo "Start the services first: ./scripts/start.sh"
  exit 1
fi

# Create backup directory
mkdir -p "$BACKUP_SUBDIR"

# Backup each database
for DB in "${DATABASES[@]}"; do
  echo "Backing up database: $DB..."
  docker exec stargate-postgres pg_dump -U "$POSTGRES_USER" "$DB" > "$BACKUP_SUBDIR/${DB}.sql"
  
  if [ $? -eq 0 ]; then
    echo "  ✓ $DB backed up successfully"
  else
    echo "  ✗ Failed to backup $DB"
  fi
done

# Create a compressed archive
echo ""
echo "Creating compressed archive..."
cd "$BACKUP_DIR"
tar -czf "${TIMESTAMP}.tar.gz" "$TIMESTAMP"
rm -rf "$TIMESTAMP"

ARCHIVE_PATH="$BACKUP_DIR/${TIMESTAMP}.tar.gz"
ARCHIVE_SIZE=$(du -h "$ARCHIVE_PATH" | cut -f1)

echo ""
echo "============================================"
echo "  Backup Complete"
echo "============================================"
echo ""
echo "Archive: $ARCHIVE_PATH"
echo "Size: $ARCHIVE_SIZE"
echo ""

# Cleanup old backups (keep last 7 days)
echo "Cleaning up backups older than 7 days..."
find "$BACKUP_DIR" -name "*.tar.gz" -type f -mtime +7 -delete 2>/dev/null || true
echo "Done."
echo ""
