#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SECRETS_DIR="$PROJECT_DIR/secrets"
KEYS_FILE="$SECRETS_DIR/vault-keys.json"
ENV_FILE="$PROJECT_DIR/.env"

cd "$PROJECT_DIR"

echo "============================================"
echo "  Stargate Local Development Environment"
echo "============================================"
echo ""

# Create secrets directory if it doesn't exist
mkdir -p "$SECRETS_DIR"

# Check if we need to login to registry
echo "Checking Docker registry access..."
if ! docker pull registry.vereign.io/svdh/smimekeys:latest --quiet 2>/dev/null; then
  echo ""
  echo "WARNING: Cannot pull from registry.vereign.io"
  echo "Please login first: docker login registry.vereign.io"
  echo ""
  read -p "Do you want to continue anyway? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

# Function to update .env file with vault token
update_env_token() {
  local token="$1"
  if grep -q "^VAULT_TOKEN=" "$ENV_FILE"; then
    # Update existing token
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "s/^VAULT_TOKEN=.*/VAULT_TOKEN=$token/" "$ENV_FILE"
    else
      sed -i "s/^VAULT_TOKEN=.*/VAULT_TOKEN=$token/" "$ENV_FILE"
    fi
  else
    # Add token
    echo "VAULT_TOKEN=$token" >> "$ENV_FILE"
  fi
  echo "Updated VAULT_TOKEN in .env file"
}

# Check if this is first run or restart
if [ -f "$KEYS_FILE" ]; then
  echo "Found existing Vault keys. This appears to be a restart."
  echo ""
  
  # Extract token for .env
  ROOT_TOKEN=$(jq -r '.root_token' "$KEYS_FILE")
  update_env_token "$ROOT_TOKEN"
  
  # Start infrastructure first
  echo "Starting infrastructure services..."
  docker compose up -d postgres vault minio
  
  echo "Waiting for Vault to start..."
  sleep 5
  
  # Unseal Vault
  echo "Unsealing Vault..."
  UNSEAL_KEY_1=$(jq -r '.unseal_keys_b64[0]' "$KEYS_FILE")
  UNSEAL_KEY_2=$(jq -r '.unseal_keys_b64[1]' "$KEYS_FILE")
  UNSEAL_KEY_3=$(jq -r '.unseal_keys_b64[2]' "$KEYS_FILE")
  
  docker exec svdh-vault vault operator unseal "$UNSEAL_KEY_1" || true
  docker exec svdh-vault vault operator unseal "$UNSEAL_KEY_2" || true
  docker exec svdh-vault vault operator unseal "$UNSEAL_KEY_3" || true
  
  echo "Vault unsealed!"
  
  # Start remaining services
  echo "Starting application services..."
  docker compose up -d
  
else
  echo "First time setup detected."
  echo ""
  
  # Start everything - vault-init will handle initialization
  echo "Starting all services..."
  docker compose up -d
  
  echo ""
  echo "Waiting for Vault initialization..."
  sleep 10
  
  # Wait for vault-init to complete
  echo "Waiting for vault-init container to finish..."
  docker compose logs -f vault-init 2>/dev/null &
  LOG_PID=$!
  
  # Wait for the container to exit
  while docker compose ps vault-init 2>/dev/null | grep -q "running"; do
    sleep 2
  done
  
  kill $LOG_PID 2>/dev/null || true
  
  # Check if keys were generated
  if [ -f "$KEYS_FILE" ]; then
    ROOT_TOKEN=$(jq -r '.root_token' "$KEYS_FILE")
    update_env_token "$ROOT_TOKEN"
    
    echo ""
    echo "============================================"
    echo "  Vault initialized successfully!"
    echo "============================================"
    echo ""
    echo "Root Token: $ROOT_TOKEN"
    echo ""
    echo "Keys saved to: $KEYS_FILE"
    echo "IMPORTANT: Back up this file securely!"
    echo ""
  else
    echo "WARNING: Vault keys file not found."
    echo "Check vault-init logs: docker compose logs vault-init"
  fi
fi

echo ""
echo "============================================"
echo "  Checking service status..."
echo "============================================"
echo ""

sleep 5
docker compose ps

echo ""
echo "============================================"
echo "  Service URLs:"
echo "============================================"
echo ""
echo "  smimekeys-client:  http://localhost:8081"
echo "  policy:            http://localhost:8082"
echo "  idagent:           http://localhost:8083"
echo "  mxengine:          http://localhost:8084"
echo "  mxengine SMTP:     localhost:1587"
echo ""
echo "  Vault UI:          http://localhost:8200"
echo "  MinIO Console:     http://localhost:9001"
echo "  PostgreSQL:        localhost:5432"
echo ""
echo "============================================"
echo "  Useful commands:"
echo "============================================"
echo ""
echo "  View logs:         docker compose logs -f [service]"
echo "  Stop all:          docker compose down"
echo "  Stop + clean:      docker compose down -v"
echo "  Restart service:   docker compose restart [service]"
echo ""
