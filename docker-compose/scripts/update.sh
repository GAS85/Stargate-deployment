#!/bin/bash
set -e

# ==============================================================================
# Stargate Update Script
# ==============================================================================
# Re-reads customer-config.sh, regenerates .env, and restarts all services.
#
# Use cases:
#   - Bump image versions (change *_VERSION in customer-config.sh, then run this)
#   - Update mail domains, WireGuard config, or any other customer settings
#   - Change passwords or credentials (except VAULT_TOKEN, which is preserved)
#
# Usage:
#   ./scripts/update.sh              # regenerate .env and restart
#   ./scripts/update.sh --env-only   # regenerate .env without restarting
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_DIR/.env"

# Source install.sh for shared functions (load_customer_config, generate_env_file, etc.)
STARGATE_SOURCE_ONLY=1 source "$SCRIPT_DIR/install.sh"

# Parse arguments
ENV_ONLY=false
for arg in "$@"; do
  case "$arg" in
    --env-only) ENV_ONLY=true ;;
    -h|--help)
      echo "Usage: $0 [--env-only]"
      echo ""
      echo "  --env-only   Regenerate .env without restarting services"
      echo ""
      echo "Edit customer-config.sh first, then run this script to apply changes."
      exit 0
      ;;
    *)
      echo "Unknown option: $arg"
      echo "Usage: $0 [--env-only]"
      exit 1
      ;;
  esac
done

cd "$PROJECT_DIR"

echo "============================================"
echo "  Stargate Configuration Update"
echo "============================================"
echo ""

# Preserve VAULT_TOKEN from current .env (tied to Vault unseal state)
EXISTING_VAULT_TOKEN=""
if [ -f "$ENV_FILE" ]; then
  EXISTING_VAULT_TOKEN=$(grep '^VAULT_TOKEN=' "$ENV_FILE" | cut -d= -f2- | tr -d '"' || true)
fi

if [ -z "$EXISTING_VAULT_TOKEN" ]; then
  echo "WARNING: No VAULT_TOKEN found in current .env."
  echo "  Vault-dependent services will not work until init-vault.sh is run."
  echo ""
fi

# Load customer config (validates required fields, derives defaults)
load_customer_config

# Regenerate .env
generate_env_file

# Restore VAULT_TOKEN (generate_env_file writes it blank)
if [ -n "$EXISTING_VAULT_TOKEN" ]; then
  sed -i "s|^VAULT_TOKEN=.*|VAULT_TOKEN=$EXISTING_VAULT_TOKEN|" "$ENV_FILE"
  echo "Preserved VAULT_TOKEN from previous .env"
  echo ""
fi

if [ "$ENV_ONLY" = true ]; then
  echo "Done. .env updated (--env-only, services not restarted)."
  echo ""
  echo "To apply changes: docker compose down && docker compose up -d"
  exit 0
fi

# Restart services
echo "Stopping services..."
docker compose down

echo ""
echo "Starting services with updated configuration..."
docker compose up -d

echo ""
echo "============================================"
echo "  Update Complete"
echo "============================================"
echo ""
echo "  Changes applied from: $CONFIG_FILE"
echo "  Environment file:     $ENV_FILE"
echo ""
echo "  Verify with: docker compose ps"
echo ""
