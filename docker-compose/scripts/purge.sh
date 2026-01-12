#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SECRETS_DIR="$PROJECT_DIR/secrets"

cd "$PROJECT_DIR"

echo ""
echo "============================================"
echo "  WARNING: DATA DESTRUCTION"
echo "============================================"
echo ""
echo "This will PERMANENTLY DELETE all data:"
echo "  - PostgreSQL databases (smimekeys, policy, idagent, mxengine)"
echo "  - Vault data and secrets"
echo "  - MinIO storage"
echo "  - Vault keys (secrets/vault-keys.json)"
echo ""
echo "This action CANNOT be undone!"
echo ""
read -p "Type 'DELETE ALL DATA' to confirm: " confirmation

if [ "$confirmation" = "DELETE ALL DATA" ]; then
  echo ""
  echo "Creating backup before deletion..."
  "$SCRIPT_DIR/backup.sh" || echo "Backup failed, but continuing..."
  
  echo ""
  echo "Stopping and removing all containers and volumes..."
  docker compose down -v
  
  echo ""
  echo "Removing secrets directory..."
  rm -rf "$SECRETS_DIR"
  
  echo ""
  echo "============================================"
  echo "  All data has been deleted"
  echo "============================================"
  echo ""
  echo "To reinstall, run: ./scripts/install.sh"
  echo ""
else
  echo ""
  echo "Confirmation failed. No data was deleted."
  exit 1
fi
