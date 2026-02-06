#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SECRETS_DIR="$PROJECT_DIR/secrets"
KEYS_FILE="$SECRETS_DIR/vault-keys.json"
ENV_FILE="$PROJECT_DIR/.env"
CONFIG_FILE="$PROJECT_DIR/customer-config.sh"

# Determine Linux distribution:
if [ -f /etc/os-release ]; then
	DIST_ID=$(grep ^ID= /etc/os-release |cut -f2 -d=|sed s/\"//g)
else
	echo "File /etc/os-release not found, cannot determine Linux distribution."
	exit 1
fi

if [[ $DIST_ID == debian || $DIST_ID == ubuntu || $DIST_ID == linuxmint || $DIST_ID == kali  ]] ; then
	PKGMGR=apt
else
	PKGMGR=dnf
fi

cd "$PROJECT_DIR"

echo "============================================"
echo "  Stargate Installation"
echo "============================================"
echo ""

# Check if already installed
if [ -f "$KEYS_FILE" ]; then
  echo "ERROR: Installation already completed."
  echo "Vault keys found at: $KEYS_FILE"
  echo ""
  echo "To start services, use: ./scripts/start.sh"
  echo "To reinstall, first run: ./scripts/stop.sh --purge"
  exit 1
fi

install_docker() {
  echo "Installing Docker from official repository..."
  if [[ $PKGMGR == apt ]] ; then
	  sudo $PKGMGR update -y && sudo $PKGMGR upgrade -y
	  sudo $PKGMGR remove -y docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc 2>/dev/null || true
	  sudo $PKGMGR install -y ca-certificates curl
	  # Add Docker's official GPG key
	  sudo install -m 0755 -d /etc/apt/keyrings
	  sudo curl -fsSL https://download.docker.com/linux/$DIST_ID/gpg -o /etc/apt/keyrings/docker.asc
	  sudo chmod a+r /etc/apt/keyrings/docker.asc
	  # Add the repository
	    echo \
		    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/$DIST_ID \
		    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
		    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	  sudo $PKGMGR update -y
  else 	
	  sudo $PKGMGR update -y
	  sudo $PKGMGR remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine podman runc
	  sudo rpm --import https://download.docker.com/linux/rhel/gpg
	  sudo $PKGMGR -y install dnf-plugins-core
	  sudo $PKGMGR config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
  fi
  # Install Docker
  sudo $PKGMGR install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin jq
  echo "Docker installed successfully!"
  sudo systemctl enable --now docker
  docker --version
  docker compose version
}

check_dependencies() {
  local missing=()
  
  if ! command -v docker &> /dev/null; then
    missing+=("docker")
  fi
  
  if ! docker compose version &> /dev/null 2>&1; then
    missing+=("docker-compose-plugin")
  fi
  
  if ! command -v jq &> /dev/null; then
    missing+=("jq")
  fi
  
  if [ ${#missing[@]} -gt 0 ]; then
    echo "Missing dependencies: ${missing[*]}"
    echo ""
    echo "Installing Docker and dependencies..."
    install_docker
  fi
}

# Function to update .env file with vault token
update_env_token() {
  local token="$1"
  if grep -q "^VAULT_TOKEN=" "$ENV_FILE"; then
      sed -i "s/^VAULT_TOKEN=.*/VAULT_TOKEN=$token/" "$ENV_FILE"
  else
    echo "VAULT_TOKEN=$token" >> "$ENV_FILE"
  fi
  echo "Updated VAULT_TOKEN in .env file"
}

# Generate a random password
generate_password() {
  local length=${1:-24}
  tr -dc 'A-Za-z0-9' < /dev/urandom | head -c "$length"
}

# Generate UUID v7 (time-ordered UUID)
# Format: tttttttt-tttt-7xxx-yxxx-xxxxxxxxxxxx
# where t=timestamp(ms), 7=version, y=variant(8-b), x=random
generate_uuid7() {
  # Get current timestamp in milliseconds
  local ts_ms=$(date +%s%3N)
  # Convert to hex (48 bits = 12 hex chars)
  local ts_hex=$(printf '%012x' "$ts_ms")
  # Generate random bytes (need 10 bytes = 20 hex chars) using od (more portable than xxd)
  local rand=$(head -c 10 /dev/urandom | od -An -tx1 | tr -d ' \n')
  # Build UUID v7:
  # Positions: tttttttt-tttt-7rrr-Vrrr-rrrrrrrrrrrr
  # Extract parts
  local time_high="${ts_hex:0:8}"
  local time_mid="${ts_hex:8:4}"
  local rand_a="${rand:0:3}"
  local variant_byte=$((0x80 | (0x${rand:3:2} & 0x3f)))
  local variant_hex=$(printf '%02x' "$variant_byte")
  local rand_b="${rand:5:2}"
  local rand_c="${rand:7:12}"
  # Format: xxxxxxxx-xxxx-7xxx-yxxx-xxxxxxxxxxxx
  echo "${time_high}-${time_mid}-7${rand_a}-${variant_hex}${rand_b}-${rand_c}"
}

# ==============================================================================
# Customer Configuration Loading
# ==============================================================================

load_customer_config() {
  echo "============================================"
  echo "  Loading Customer Configuration"
  echo "============================================"
  echo ""
  
  if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Customer configuration file not found!"
    echo ""
    echo "Please fill in the customer configuration file:"
    echo "  $CONFIG_FILE"
    echo ""
    echo "Then run this script again."
    exit 1
  fi
  
  # Source the config file
  source "$CONFIG_FILE"
  
  # Validate required fields
  local missing_required=()
  
  [ -z "$CUSTOMER_NAME" ] && missing_required+=("CUSTOMER_NAME")
  [ -z "$DEPLOYMENT_NAME" ] && missing_required+=("DEPLOYMENT_NAME")
  [ -z "$MAIL_DOMAIN" ] && missing_required+=("MAIL_DOMAIN")
  [ -z "$CERT_DNS_NAMES" ] && missing_required+=("CERT_DNS_NAMES")
  [ -z "$CERT_ORGANIZATION" ] && missing_required+=("CERT_ORGANIZATION")
  [ -z "$CERT_COMMON_NAME" ] && missing_required+=("CERT_COMMON_NAME")
  [ -z "$CERT_COUNTRIES" ] && missing_required+=("CERT_COUNTRIES")
  
  if [ ${#missing_required[@]} -gt 0 ]; then
    echo "ERROR: Missing required configuration values:"
    for field in "${missing_required[@]}"; do
      echo "  - $field"
    done
    echo ""
    echo "Please fill in all required fields in:"
    echo "  $CONFIG_FILE"
    exit 1
  fi
  
  # Set defaults for optional fields
  POSTGRES_USER="${POSTGRES_USER:-postgres}"
  POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-$(generate_password)}"
  MINIO_ROOT_USER="${MINIO_ROOT_USER:-minioadmin}"
  MINIO_ROOT_PASSWORD="${MINIO_ROOT_PASSWORD:-$(generate_password)}"
  S3_BUCKET_NAME="${S3_BUCKET_NAME:-stargate-bucket}"
  
  SMIMEKEYS_VERSION="${SMIMEKEYS_VERSION:-latest}"
  POLICY_VERSION="${POLICY_VERSION:-latest}"
  IDAGENT_VERSION="${IDAGENT_VERSION:-latest}"
  MXENGINE_VERSION="${MXENGINE_VERSION:-latest}"
  
  MAIL_HOSTNAME="${MAIL_HOSTNAME:-mail.${MAIL_DOMAIN}}"
  POSTFIX_ENABLE_IPV6="${POSTFIX_ENABLE_IPV6:-false}"
  DNS_TIMEOUT="${DNS_TIMEOUT:-2}"
  
  LOKI_URL="${LOKI_URL:-https://loki.k8s.vereign-cdn.com}"
  
  # WireGuard local configuration
  WG_LOCAL_IP="${WG_LOCAL_IP:-10.0.0.1}"
  WG_INTERFACE_PORT="${WG_INTERFACE_PORT:-51820}"
  WG_PRIVATE_KEY="${WG_PRIVATE_KEY:-}"  # Optional - if empty, idagent will generate
  
  # WireGuard peer configuration - validate required fields
  if [ -z "$WG_PEER_PUBLIC_KEY" ]; then
    missing_required+=("WG_PEER_PUBLIC_KEY")
  fi
  if [ -z "$WG_PEER_ENDPOINT" ]; then
    missing_required+=("WG_PEER_ENDPOINT")
  fi
  
  if [ ${#missing_required[@]} -gt 0 ]; then
    echo "ERROR: Missing required configuration values:"
    for field in "${missing_required[@]}"; do
      echo "  - $field"
    done
    echo ""
    echo "Please fill in all required fields in:"
    echo "  $CONFIG_FILE"
    exit 1
  fi
  
  # Generate UUID v7 for connection if not provided
  WG_PEER_CONNECTION_ID="${WG_PEER_CONNECTION_ID:-$(generate_uuid7)}"
  WG_PEER_NAME="${WG_PEER_NAME:-default}"
  WG_PEER_IP="${WG_PEER_IP:-10.0.0.2}"
  WG_PEER_PORT="${WG_PEER_PORT:-9090}"
  WG_PEER_ALLOWED_IPS="${WG_PEER_ALLOWED_IPS:-${WG_PEER_IP}/32}"
  WG_PEER_EXTERNAL_ID="${WG_PEER_EXTERNAL_ID:-}"
  WG_PEER_DESCRIPTION="${WG_PEER_DESCRIPTION:-WireGuard peer connection}"
  
  echo "Customer: $CUSTOMER_NAME"
  echo "Deployment: $DEPLOYMENT_NAME"
  echo "Mail Domain: $MAIL_DOMAIN"
  echo "WireGuard Peer: $WG_PEER_NAME ($WG_PEER_ENDPOINT)"
  echo ""
}

# ==============================================================================
# Environment File Generation
# ==============================================================================

generate_env_file() {
  echo "============================================"
  echo "  Generating Environment File"
  echo "============================================"
  echo ""
  
  cat > "$ENV_FILE" << EOF
# ==============================================================================
# Stargate Environment Configuration
# ==============================================================================
# Generated from customer-config.sh on $(date)
# Customer: $CUSTOMER_NAME
# Deployment: $DEPLOYMENT_NAME
# ==============================================================================

# PostgreSQL
POSTGRES_USER=$POSTGRES_USER
POSTGRES_PASSWORD=$POSTGRES_PASSWORD

# Vault (auto-populated after initialization)
VAULT_TOKEN=

# MinIO (S3)
MINIO_ROOT_USER=$MINIO_ROOT_USER
MINIO_ROOT_PASSWORD=$MINIO_ROOT_PASSWORD
S3_BUCKET_NAME=$S3_BUCKET_NAME

# Application Versions
SMIMEKEYS_VERSION=$SMIMEKEYS_VERSION
POLICY_VERSION=$POLICY_VERSION
IDAGENT_VERSION=$IDAGENT_VERSION
MXENGINE_VERSION=$MXENGINE_VERSION

# Postfix Mail Relay
MAIL_DOMAIN=$MAIL_DOMAIN
MAIL_HOSTNAME=$MAIL_HOSTNAME
POSTFIX_ENABLE_IPV6=$POSTFIX_ENABLE_IPV6
DNS_TIMEOUT=$DNS_TIMEOUT
DNS_SERVER=${DNS_SERVER:-}
RELAYHOST=${RELAYHOST:-}
# Leave empty for auto-detection (Docker networks + SPF records)
POSTFIX_MYNETWORKS=${POSTFIX_MYNETWORKS:-}

# Logging (Promtail -> Loki)
LOKI_URL=$LOKI_URL
PROMTAIL_HOSTNAME=$DEPLOYMENT_NAME

# Policy Sync (optional - syncs policies from Git repo)
# To enable: docker compose --profile policy-sync up -d
POLICY_SYNC_VERSION=${POLICY_SYNC_VERSION:-dev}
POLICY_SYNC_REPO_URL=${POLICY_SYNC_REPO_URL:-}
POLICY_SYNC_REPO_USER=${POLICY_SYNC_REPO_USER:-}
POLICY_SYNC_REPO_PASS=${POLICY_SYNC_REPO_PASS:-}
POLICY_SYNC_REPO_BRANCH=${POLICY_SYNC_REPO_BRANCH:-}
POLICY_SYNC_REPO_FOLDER=${POLICY_SYNC_REPO_FOLDER:-}
POLICY_SYNC_INTERVAL=${POLICY_SYNC_INTERVAL:-1h}

# WireGuard Local Configuration
WG_LOCAL_IP=$WG_LOCAL_IP
WG_INTERFACE_PORT=$WG_INTERFACE_PORT

# WireGuard Private Key (optional - if set, written to Vault for idagent)
WG_PRIVATE_KEY=${WG_PRIVATE_KEY:-}

# WireGuard Peer Configuration
# Connection to remote IDAgent for sealed message delivery
WG_PEER_CONNECTION_ID=$WG_PEER_CONNECTION_ID
WG_PEER_NAME=$WG_PEER_NAME
WG_PEER_PUBLIC_KEY=$WG_PEER_PUBLIC_KEY
WG_PEER_ENDPOINT=$WG_PEER_ENDPOINT
WG_PEER_IP=$WG_PEER_IP
WG_PEER_PORT=$WG_PEER_PORT
WG_PEER_ALLOWED_IPS=$WG_PEER_ALLOWED_IPS
WG_PEER_EXTERNAL_ID=$WG_PEER_EXTERNAL_ID
WG_PEER_DESCRIPTION=$WG_PEER_DESCRIPTION
EOF

  echo "Environment file created: $ENV_FILE"
  echo ""
}

# Function to generate S/MIME key and CSR
generate_smime_key_and_csr() {
  echo ""
  echo "============================================"
  echo "  S/MIME Key and CSR Generation"
  echo "============================================"
  echo ""
  echo "Generating signing key and CSR using configuration:"
  echo "  DNS Names: $CERT_DNS_NAMES"
  echo "  Organization: $CERT_ORGANIZATION"
  echo "  Common Name: $CERT_COMMON_NAME"
  echo "  Countries: $CERT_COUNTRIES"
  echo ""
  
  # Convert comma-separated DNS names to JSON array
  DNS_NAMES_JSON=$(echo "$CERT_DNS_NAMES" | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | jq -R . | jq -s .)
  
  # Convert comma-separated countries to JSON array
  COUNTRY_JSON=$(echo "$CERT_COUNTRIES" | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | jq -R . | jq -s .)
  
  echo "Waiting for smimekeys-client to be ready..."
  
  # Wait for smimekeys-client to be ready
  for i in {1..30}; do
    if curl -s http://localhost:8081/liveness > /dev/null 2>&1; then
      break
    fi
    echo "  Attempt $i/30..."
    sleep 2
  done
  
  if ! curl -s http://localhost:8081/liveness > /dev/null 2>&1; then
    echo "ERROR: smimekeys-client not responding after 60 seconds"
    return 1
  fi
  
  # Step 1: Generate key
  echo "Generating RSA key..."
  KEY_RESPONSE=$(curl -s --location 'http://localhost:8081/v1/keys/gen' \
    --header 'Content-Type: application/json' \
    --header 'Accept: application/json' \
    --data '{
      "keySize": 2048,
      "keyType": "rsa",
      "keyUsage": 5
    }')
  
  KEY_ID=$(echo "$KEY_RESPONSE" | jq -r '.keyId // empty')
  
  if [ -z "$KEY_ID" ]; then
    echo "ERROR: Failed to generate key"
    echo "Response: $KEY_RESPONSE"
    return 1
  fi
  
  echo "Key generated successfully!"
  echo "Key ID: $KEY_ID"
  echo ""
  
  # Step 2: Generate CSR
  echo "Generating CSR..."
  CSR_RESPONSE=$(curl -s --location 'http://localhost:8081/v1/certs/csr' \
    --header 'Content-Type: application/json' \
    --header 'Accept: application/json' \
    --data "{
      \"dnsNames\": $DNS_NAMES_JSON,
      \"keyId\": \"$KEY_ID\",
      \"subjectCN\": \"$CERT_COMMON_NAME\",
      \"subjectCountry\": $COUNTRY_JSON,
      \"subjectOrg\": \"$CERT_ORGANIZATION\"
    }")
  
  # Save CSR to file
  CSR_FILE="$SECRETS_DIR/signing-key.csr"
  echo "$CSR_RESPONSE" | jq -r '.csr // empty' > "$CSR_FILE" 2>/dev/null || true
  
  echo ""
  echo "============================================"
  echo "  CSR Generated Successfully"
  echo "============================================"
  echo ""
  echo "$CSR_RESPONSE" | jq . 2>/dev/null || echo "$CSR_RESPONSE"
  echo ""
  
  if [ -s "$CSR_FILE" ]; then
    echo "CSR saved to: $CSR_FILE"
  fi
  echo ""
}

# Function to setup backup cron job
setup_backup_cron() {
  echo ""
  echo "Setting up daily backup cron job..."
  
  BACKUP_SCRIPT="$SCRIPT_DIR/backup.sh"
  CRON_JOB="0 2 * * * $BACKUP_SCRIPT >> $PROJECT_DIR/backups/cron.log 2>&1"
  
  # Check if cron job already exists
  if crontab -l 2>/dev/null | grep -q "$BACKUP_SCRIPT"; then
    echo "Backup cron job already exists."
  else
    # Add cron job
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo "Daily backup scheduled at 2:00 AM"
  fi
  
  # Create backups directory
  mkdir -p "$PROJECT_DIR/backups"
}

# Function to save Vault token to customer-config.sh for persistence
save_vault_token_to_config() {
  local token="$1"
  
  echo ""
  echo "============================================"
  echo "  Saving Vault Token to Config"
  echo "============================================"
  echo ""
  
  # Check if VAULT_TOKEN is empty or missing in customer-config.sh
  if grep -q '^VAULT_TOKEN=""' "$CONFIG_FILE" || grep -q '^VAULT_TOKEN=$' "$CONFIG_FILE" || ! grep -q '^VAULT_TOKEN=' "$CONFIG_FILE"; then
    # Update or add the token
    if grep -q '^VAULT_TOKEN=' "$CONFIG_FILE"; then
      sed -i "s|^VAULT_TOKEN=.*|VAULT_TOKEN=\"$token\"|" "$CONFIG_FILE"
    else
      # Add to file if not present
      echo "" >> "$CONFIG_FILE"
      echo "VAULT_TOKEN=\"$token\"" >> "$CONFIG_FILE"
    fi
    echo "Vault token saved to customer-config.sh"
    echo ""
    echo "  Token: ${token:0:15}...${token: -10}"
    echo ""
    echo "  IMPORTANT: Back up customer-config.sh before recreating the VM!"
    echo "  The same token will be used on restore."
  else
    echo "Vault token already configured in customer-config.sh"
  fi
}

# Function to extract WireGuard key from Vault and save to customer-config.sh
save_wireguard_key_to_config() {
  echo ""
  echo "============================================"
  echo "  Saving WireGuard Key to Config"
  echo "============================================"
  echo ""
  
  # Wait for idagent to generate the key (it needs a moment after start)
  echo "Waiting for IDAgent to initialize WireGuard key..."
  sleep 5
  
  # Extract the WireGuard private key from Vault
  WG_KEY=$(docker exec -e VAULT_TOKEN="$ROOT_TOKEN" stargate-vault \
    vault kv get -address=http://127.0.0.1:8200 -field=wg_private_key secret-idagent/wg_private_key 2>/dev/null || echo "")
  
  if [ -z "$WG_KEY" ]; then
    echo "WARNING: Could not extract WireGuard key from Vault."
    echo "IDAgent may not have started yet. You can extract it later with:"
    echo "  docker exec stargate-vault vault kv get -address=http://127.0.0.1:8200 secret-idagent/wg_private_key"
    return 1
  fi
  
  # Get the public key from idagent logs
  WG_PUBKEY=$(docker logs stargate-idagent 2>&1 | grep "wireguard public key:" | head -1 | sed 's/.*wireguard public key: //' | tr -d '[:space:]')
  
  # Check if WG_PRIVATE_KEY is already set in customer-config.sh
  if grep -q '^WG_PRIVATE_KEY=""' "$CONFIG_FILE" || grep -q "^WG_PRIVATE_KEY=\$" "$CONFIG_FILE" || ! grep -q '^WG_PRIVATE_KEY=' "$CONFIG_FILE"; then
    # Update or add the key
    if grep -q '^WG_PRIVATE_KEY=' "$CONFIG_FILE"; then
      sed -i "s|^WG_PRIVATE_KEY=.*|WG_PRIVATE_KEY=\"$WG_KEY\"|" "$CONFIG_FILE"
    else
      # Add after WireGuard Configuration section header
      sed -i "/^# Local WireGuard IP address/i WG_PRIVATE_KEY=\"$WG_KEY\"\n" "$CONFIG_FILE"
    fi
    echo "WireGuard private key saved to customer-config.sh"
    echo ""
    echo "  Private Key: ${WG_KEY:0:10}...${WG_KEY: -10}"
    echo "  Public Key:  $WG_PUBKEY"
    echo ""
    echo "  IMPORTANT: Back up customer-config.sh before recreating the VM!"
    echo "  The same key will be used on next install."
  else
    echo "WireGuard key already configured in customer-config.sh"
  fi
}

# ============================================
# Main Installation
# ============================================

# Check dependencies first
check_dependencies


# Load and validate customer configuration
load_customer_config

# Create directories
mkdir -p "$SECRETS_DIR"
mkdir -p "$PROJECT_DIR/backups"

# Generate .env file from customer config
generate_env_file

# Start all services
echo ""
echo "Starting all services..."
docker compose up -d

echo ""
echo "Waiting for Vault initialization..."
sleep 10

# Wait for vault-init to complete
echo "Waiting for vault-init container to finish..."
docker compose logs -f vault-init 2>/dev/null &
LOG_PID=$!

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
  
  # Save Vault token to customer-config.sh for persistence across VM recreations
  save_vault_token_to_config "$ROOT_TOKEN"
  
  # Restart application services to pick up the new VAULT_TOKEN
  echo "Restarting application services with Vault token..."
  docker compose up -d --force-recreate smimekeys-client policy idagent mxengine
  echo "Application services restarted."
  
  # Wait for services to be ready
  sleep 5
  
  # Generate S/MIME key and CSR
  generate_smime_key_and_csr
  
  # Setup backup cron job
  setup_backup_cron
  
  # Save WireGuard key to customer-config.sh for persistence
  save_wireguard_key_to_config

else
  echo "ERROR: Vault keys file not found."
  echo "Check vault-init logs: docker compose logs vault-init"
  exit 1
fi

echo ""
echo "============================================"
echo "  Checking service status..."
echo "============================================"
echo ""

sleep 3
docker compose ps

echo ""
echo "============================================"
echo "  Installation Complete!"
echo "============================================"
echo ""
echo "  Customer: $CUSTOMER_NAME"
echo "  Deployment: $DEPLOYMENT_NAME"
echo ""
echo "  Service URLs:"
echo "  -------------"
echo "  smimekeys-client:  http://localhost:8081"
echo "  policy:            http://localhost:8082"
echo "  idagent:           http://localhost:8083"
echo "  mxengine:          http://localhost:8084"
echo "  mxengine SMTP:     localhost:1587"
echo ""
echo "  Vault UI:          http://localhost:8200"
echo "  MinIO Console:     http://localhost:9001"
echo "  PostgreSQL:        localhost:5432"
echo "  Postfix SMTP:      localhost:25"
echo ""
echo "  Monitoring:"
echo "  -----------"
echo "  Node Exporter:     http://localhost:9100/metrics"
echo "  Promtail:          Logs -> $LOKI_URL"
echo ""
echo "  Scripts:"
echo "  --------"
echo "  Start services:    ./scripts/start.sh"
echo "  Stop services:     ./scripts/stop.sh"
echo "  Backup databases:  ./scripts/backup.sh"
echo "  Destroy all data:  ./scripts/stop.sh --purge"
echo ""
echo "  Backups:"
echo "  --------"
echo "  Daily backups scheduled at 2:00 AM"
echo "  Backup location: $PROJECT_DIR/backups/"
echo ""
echo "  Configuration:"
echo "  --------------"
echo "  Customer config:   $CONFIG_FILE"
echo "  Environment file:  $ENV_FILE"
echo "  Vault keys:        $KEYS_FILE"
echo "  CSR file:          $SECRETS_DIR/signing-key.csr"
echo ""
echo "  IMPORTANT: Back up customer-config.sh before recreating the VM!"
echo "  It now contains your WireGuard private key for persistence."
echo ""
