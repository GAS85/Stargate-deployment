#!/bin/sh
set -e

SECRETS_DIR="/secrets"
INIT_FILE="$SECRETS_DIR/.vault-initialized"
KEYS_FILE="$SECRETS_DIR/vault-keys.json"

echo "=== Vault Initialization Script ==="
echo "Waiting for Vault to be ready..."

# Wait for Vault to be available
until vault status -address=http://vault:8200 2>/dev/null | grep -q "Initialized"; do
  sleep 2
done

# Check if Vault is already initialized
INITIALIZED=$(vault status -address=http://vault:8200 -format=json 2>/dev/null | jq -r '.initialized')

if [ "$INITIALIZED" = "true" ]; then
  echo "Vault is already initialized."
  
  # Check if sealed
  SEALED=$(vault status -address=http://vault:8200 -format=json | jq -r '.sealed')
  
  if [ "$SEALED" = "true" ]; then
    echo "Vault is sealed. Attempting to unseal..."
    
    if [ -f "$KEYS_FILE" ]; then
      # Unseal with stored keys
      UNSEAL_KEY_1=$(jq -r '.unseal_keys_b64[0]' "$KEYS_FILE")
      UNSEAL_KEY_2=$(jq -r '.unseal_keys_b64[1]' "$KEYS_FILE")
      UNSEAL_KEY_3=$(jq -r '.unseal_keys_b64[2]' "$KEYS_FILE")
      
      vault operator unseal -address=http://vault:8200 "$UNSEAL_KEY_1"
      vault operator unseal -address=http://vault:8200 "$UNSEAL_KEY_2"
      vault operator unseal -address=http://vault:8200 "$UNSEAL_KEY_3"
      
      echo "Vault unsealed successfully!"
    else
      echo "ERROR: Vault keys file not found at $KEYS_FILE"
      echo "Cannot unseal Vault automatically."
      exit 1
    fi
  fi
  
  # Verify we can authenticate
  if [ -f "$KEYS_FILE" ]; then
    ROOT_TOKEN=$(jq -r '.root_token' "$KEYS_FILE")
    export VAULT_TOKEN="$ROOT_TOKEN"
  fi
  
else
  echo "Initializing Vault for the first time..."
  
  # Use predefined root token if VAULT_ROOT_TOKEN is set (for reproducible deployments)
  # Otherwise Vault will generate a random token
  INIT_ARGS="-address=http://vault:8200 -key-shares=5 -key-threshold=3 -format=json"
  if [ -n "$VAULT_ROOT_TOKEN" ]; then
    echo "Using predefined root token from VAULT_ROOT_TOKEN environment variable"
    INIT_ARGS="$INIT_ARGS -root-token-id=$VAULT_ROOT_TOKEN"
  fi
  
  # Initialize Vault with 5 key shares and 3 key threshold
  vault operator init $INIT_ARGS > "$KEYS_FILE"
  
  chmod 600 "$KEYS_FILE"
  
  echo "Vault initialized. Keys stored in $KEYS_FILE"
  echo ""
  echo "=========================================="
  echo "IMPORTANT: Back up $KEYS_FILE securely!"
  echo "=========================================="
  echo ""
  
  # Extract keys and unseal
  UNSEAL_KEY_1=$(jq -r '.unseal_keys_b64[0]' "$KEYS_FILE")
  UNSEAL_KEY_2=$(jq -r '.unseal_keys_b64[1]' "$KEYS_FILE")
  UNSEAL_KEY_3=$(jq -r '.unseal_keys_b64[2]' "$KEYS_FILE")
  ROOT_TOKEN=$(jq -r '.root_token' "$KEYS_FILE")
  
  echo "Unsealing Vault..."
  vault operator unseal -address=http://vault:8200 "$UNSEAL_KEY_1"
  vault operator unseal -address=http://vault:8200 "$UNSEAL_KEY_2"
  vault operator unseal -address=http://vault:8200 "$UNSEAL_KEY_3"
  
  echo "Vault unsealed!"
  
  # Login with root token
  export VAULT_TOKEN="$ROOT_TOKEN"
  
  # Create KV-v2 mounts for each service
  echo "Creating Vault KV-v2 mounts..."
  
  vault secrets enable -address=http://vault:8200 -path=secret-smimekeys-client kv-v2 || echo "secret-smimekeys-client already exists"
  vault secrets enable -address=http://vault:8200 -path=secret-policy kv-v2 || echo "secret-policy already exists"
  vault secrets enable -address=http://vault:8200 -path=secret-idagent kv-v2 || echo "secret-idagent already exists"
  vault secrets enable -address=http://vault:8200 -path=secret-mxengine kv-v2 || echo "secret-mxengine already exists"
  
  echo "Vault mounts created!"
  
  # Save root token to .env file hint
  echo ""
  echo "=========================================="
  echo "Add this to your .env file:"
  echo "VAULT_TOKEN=$ROOT_TOKEN"
  echo "=========================================="
  echo ""
  
  # Also update the .env file token placeholder
  touch "$INIT_FILE"
fi

# Output current Vault status
echo ""
echo "=== Vault Status ==="
vault status -address=http://vault:8200

echo ""
echo "=== Vault Mounts ==="
if [ -f "$KEYS_FILE" ]; then
  ROOT_TOKEN=$(jq -r '.root_token' "$KEYS_FILE")
  VAULT_TOKEN="$ROOT_TOKEN" vault secrets list -address=http://vault:8200 2>/dev/null || echo "Could not list mounts"
fi

echo ""
echo "Vault initialization complete!"
