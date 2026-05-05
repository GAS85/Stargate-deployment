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
      sed -i "s/^VAULT_TOKEN=.*/VAULT_TOKEN=\"$token\"/" "$ENV_FILE"
  else
    echo "VAULT_TOKEN=\"$token\"" >> "$ENV_FILE"
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
# MAIL_HOSTNAME validation
# ==============================================================================

# Reject obviously-bad MAIL_HOSTNAME values that produce a non-functional
# deployment: empty, placeholder example.com, localhost, single-label, or
# anything that does not look like a DNS FQDN.
validate_mail_hostname() {
  local h="$1"

  if [ -z "$h" ]; then
    echo "ERROR: MAIL_HOSTNAME is empty and could not be auto-derived."
    echo "  Set MAIL_HOSTNAME explicitly in customer-config.sh, e.g.:"
    echo "    MAIL_HOSTNAME=\"mail.yourdomain.ch\""
    exit 1
  fi

  case "$h" in
    *.example.com|*.example.org|*.example.net|example.com|example.org|example.net)
      echo "ERROR: MAIL_HOSTNAME is set to a placeholder value: $h"
      echo "  This is the template default. Set MAIL_HOSTNAME in customer-config.sh"
      echo "  to the real public FQDN of this Stargate, e.g.:"
      echo "    MAIL_HOSTNAME=\"mail.yourdomain.ch\""
      exit 1
      ;;
    localhost|*.localdomain|*.local)
      echo "ERROR: MAIL_HOSTNAME ($h) is not a public FQDN."
      echo "  External servers and Exchange Online cannot route mail to this name."
      echo "  Set MAIL_HOSTNAME in customer-config.sh to a real public FQDN."
      exit 1
      ;;
  esac

  if ! echo "$h" | grep -qE '^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?)+$'; then
    echo "ERROR: MAIL_HOSTNAME ($h) is not a valid FQDN."
    echo "  Expected something like mail.yourdomain.ch."
    exit 1
  fi
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
  
  # Multi-domain support: MAIL_DOMAINS takes precedence, fall back to MAIL_DOMAIN
  if [ -n "$MAIL_DOMAINS" ]; then
    MAIL_DOMAIN_PRIMARY=$(echo "$MAIL_DOMAINS" | cut -d',' -f1 | tr -d ' ')
  elif [ -n "$MAIL_DOMAIN" ]; then
    MAIL_DOMAINS="$MAIL_DOMAIN"
    MAIL_DOMAIN_PRIMARY="$MAIL_DOMAIN"
  fi
  [ -z "$MAIL_DOMAINS" ] && missing_required+=("MAIL_DOMAINS")
  
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
  DASHBOARD_VERSION="${DASHBOARD_VERSION:-latest}"
  
  # Derive WG_LOCAL_IP and MXENGINE_PUBLIC_ADDRESS from SERVER_STATIC_IP
  SERVER_STATIC_IP="${SERVER_STATIC_IP:-}"
  if [ -z "$SERVER_STATIC_IP" ] && [ -n "$WG_LOCAL_IP" ] && [ "$WG_LOCAL_IP" != "10.0.0.1" ]; then
    # Backward compatibility: if SERVER_STATIC_IP not set but WG_LOCAL_IP is, use that
    SERVER_STATIC_IP="$WG_LOCAL_IP"
  fi

  if [ -z "$SERVER_STATIC_IP" ]; then
    echo "ERROR: SERVER_STATIC_IP is required."
    echo "  Set it to this server's real static public IP address."
    echo "  Example: SERVER_STATIC_IP=\"203.0.113.10\""
    exit 1
  fi

  WG_LOCAL_IP="${WG_LOCAL_IP:-$SERVER_STATIC_IP}"
  MXENGINE_PUBLIC_ADDRESS="${MXENGINE_PUBLIC_ADDRESS:-http://${SERVER_STATIC_IP}:8084}"
  KEYCLOAK_PUBLIC_URL="${KEYCLOAK_PUBLIC_URL:-https://${SERVER_STATIC_IP}:8180}"
  DASHBOARD_PUBLIC_URL="${DASHBOARD_PUBLIC_URL:-https://${SERVER_STATIC_IP}:3000}"

  MAIL_HOSTNAME="${MAIL_HOSTNAME:-mail.${MAIL_DOMAIN_PRIMARY}}"
  validate_mail_hostname "$MAIL_HOSTNAME"
  OUTBOUND_SEALER_MX_DOMAIN="${OUTBOUND_SEALER_MX_DOMAIN:-hintest.ch}"
  CERT_CA_IDAGENT_DOMAIN="${CERT_CA_IDAGENT_DOMAIN:-hintest.ch}"

  # Auto-derive certificate fields if not explicitly set
  if [ -z "$CERT_DNS_NAMES" ]; then
    CERT_DNS_NAMES="$MAIL_DOMAINS,$MAIL_HOSTNAME"
  fi
  CERT_ORGANIZATION="${CERT_ORGANIZATION:-$CUSTOMER_NAME}"
  CERT_COMMON_NAME="${CERT_COMMON_NAME:-$CUSTOMER_NAME Mail Signing}"
  OUTBOUND_SMTP_HOST="${OUTBOUND_SMTP_HOST:-postfix-relay}"
  OUTBOUND_SMTP_PORT="${OUTBOUND_SMTP_PORT:-10026}"
  POSTFIX_ENABLE_IPV6="${POSTFIX_ENABLE_IPV6:-false}"
  DNS_TIMEOUT="${DNS_TIMEOUT:-2}"
  
  LOKI_URL="${LOKI_URL:-https://loki.infra.vereign-cdn.com}"

  # Keycloak / APISIX / Dashboard
  KEYCLOAK_ADMIN_USER="${KEYCLOAK_ADMIN_USER:-admin}"
  KEYCLOAK_ADMIN_PASSWORD="${KEYCLOAK_ADMIN_PASSWORD:-$(generate_password)}"
  KEYCLOAK_APISIX_CLIENT_SECRET="${KEYCLOAK_APISIX_CLIENT_SECRET:-$(generate_password 32)}"
  KEYCLOAK_DASHBOARD_CLIENT_SECRET="${KEYCLOAK_DASHBOARD_CLIENT_SECRET:-$(generate_password 32)}"
  APISIX_ADMIN_KEY="${APISIX_ADMIN_KEY:-$(generate_password 32)}"
  DASHBOARD_SHOW_DEV_PAGES="${DASHBOARD_SHOW_DEV_PAGES:-false}"

  # WireGuard local configuration
  WG_INTERFACE_PORT="${WG_INTERFACE_PORT:-19818}"
  WG_TRANSPORT_MODE="${WG_TRANSPORT_MODE:-tcp}"
  WG_PRIVATE_KEY="${WG_PRIVATE_KEY:-}"  # Optional - if empty, idagent will generate
  
  # WireGuard peer configuration (optional at install time, validated by onboard.sh)
  WG_PEER_CONNECTION_ID="${WG_PEER_CONNECTION_ID:-$(generate_uuid7)}"
  WG_PEER_NAME="${WG_PEER_NAME:-hin-test}"
  WG_PEER_PUBLIC_KEY="${WG_PEER_PUBLIC_KEY:-ol2zlG40M7+Rn81V9RUFmkIQV2ILLmEJHZww7HfoLxA=}"
  WG_PEER_ENDPOINT="${WG_PEER_ENDPOINT:-5.102.144.182:19818}"
  WG_PEER_IP="${WG_PEER_IP:-5.102.144.182}"
  WG_PEER_PORT="${WG_PEER_PORT:-9090}"
  WG_PEER_ALLOWED_IPS="${WG_PEER_ALLOWED_IPS:-${WG_PEER_IP}/32}"
  WG_PEER_EXTERNAL_ID="${WG_PEER_EXTERNAL_ID:-hintest.ch}"
  WG_PEER_DESCRIPTION="${WG_PEER_DESCRIPTION:-Connection to HIN Test IDAgent}"
  
  echo "Customer: $CUSTOMER_NAME"
  echo "Deployment: $DEPLOYMENT_NAME"
  echo "Mail Domains: $MAIL_DOMAINS"
  if [ -n "$WG_PEER_ENDPOINT" ]; then
    echo "WireGuard Peer: $WG_PEER_NAME ($WG_PEER_ENDPOINT)"
  fi
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
POSTGRES_USER="$POSTGRES_USER"
POSTGRES_PASSWORD="$POSTGRES_PASSWORD"

# Vault (auto-populated after initialization)
VAULT_TOKEN=

# MinIO (S3)
MINIO_ROOT_USER="$MINIO_ROOT_USER"
MINIO_ROOT_PASSWORD="$MINIO_ROOT_PASSWORD"
S3_BUCKET_NAME="$S3_BUCKET_NAME"

# Application Versions
SMIMEKEYS_VERSION="$SMIMEKEYS_VERSION"
POLICY_VERSION="$POLICY_VERSION"
IDAGENT_VERSION="$IDAGENT_VERSION"
MXENGINE_VERSION="$MXENGINE_VERSION"
DASHBOARD_VERSION="$DASHBOARD_VERSION"

# Postfix Mail Relay
MAIL_DOMAINS="$MAIL_DOMAINS"
MAIL_HOSTNAME="$MAIL_HOSTNAME"
SERVER_STATIC_IP="$SERVER_STATIC_IP"
MXENGINE_PUBLIC_ADDRESS="$MXENGINE_PUBLIC_ADDRESS"
OUTBOUND_SEALER_MX_DOMAIN="$OUTBOUND_SEALER_MX_DOMAIN"
CERT_CA_IDAGENT_DOMAIN="$CERT_CA_IDAGENT_DOMAIN"
OUTBOUND_SMTP_HOST="$OUTBOUND_SMTP_HOST"
OUTBOUND_SMTP_PORT="$OUTBOUND_SMTP_PORT"
POSTFIX_ENABLE_IPV6="$POSTFIX_ENABLE_IPV6"
DNS_TIMEOUT="$DNS_TIMEOUT"
DNS_SERVER="${DNS_SERVER:-}"
RELAYHOST="${RELAYHOST:-}"
# Leave empty for auto-detection (Docker networks + SPF records)
POSTFIX_MYNETWORKS="${POSTFIX_MYNETWORKS:-}"

# Logging (Promtail -> Loki)
LOKI_URL="$LOKI_URL"
PROMTAIL_HOSTNAME="$DEPLOYMENT_NAME"

# Policy Sync (optional - syncs policies from Git repo)
# To enable: docker compose --profile policy-sync up -d
POLICY_SYNC_VERSION="${POLICY_SYNC_VERSION:-dev}"
POLICY_SYNC_REPO_URL="${POLICY_SYNC_REPO_URL:-https://github.com/Health-Info-Net-AG/Stargate-policies.git}"
POLICY_SYNC_REPO_USER="${POLICY_SYNC_REPO_USER:-}"
POLICY_SYNC_REPO_PASS="${POLICY_SYNC_REPO_PASS:-}"
POLICY_SYNC_REPO_BRANCH="${POLICY_SYNC_REPO_BRANCH:-}"
POLICY_SYNC_REPO_FOLDER="${POLICY_SYNC_REPO_FOLDER:-}"
POLICY_SYNC_INTERVAL="${POLICY_SYNC_INTERVAL:-1h}"

# Keycloak / APISIX / Dashboard
KEYCLOAK_ADMIN_USER="$KEYCLOAK_ADMIN_USER"
KEYCLOAK_ADMIN_PASSWORD="$KEYCLOAK_ADMIN_PASSWORD"
KEYCLOAK_APISIX_CLIENT_SECRET="$KEYCLOAK_APISIX_CLIENT_SECRET"
KEYCLOAK_DASHBOARD_CLIENT_SECRET="$KEYCLOAK_DASHBOARD_CLIENT_SECRET"
APISIX_ADMIN_KEY="$APISIX_ADMIN_KEY"
KEYCLOAK_PUBLIC_URL="$KEYCLOAK_PUBLIC_URL"
DASHBOARD_PUBLIC_URL="$DASHBOARD_PUBLIC_URL"
DASHBOARD_SHOW_DEV_PAGES="$DASHBOARD_SHOW_DEV_PAGES"

# WireGuard Local Configuration
WG_LOCAL_IP="$WG_LOCAL_IP"
WG_INTERFACE_PORT="$WG_INTERFACE_PORT"
WG_TRANSPORT_MODE="$WG_TRANSPORT_MODE"

# WireGuard Private Key (optional - if set, written to Vault for idagent)
WG_PRIVATE_KEY="${WG_PRIVATE_KEY:-}"

# WireGuard Peer Configuration
# Connection to remote IDAgent for sealed message delivery
WG_PEER_CONNECTION_ID="$WG_PEER_CONNECTION_ID"
WG_PEER_NAME="$WG_PEER_NAME"
WG_PEER_PUBLIC_KEY="$WG_PEER_PUBLIC_KEY"
WG_PEER_ENDPOINT="$WG_PEER_ENDPOINT"
WG_PEER_IP="$WG_PEER_IP"
WG_PEER_PORT="$WG_PEER_PORT"
WG_PEER_ALLOWED_IPS="$WG_PEER_ALLOWED_IPS"
WG_PEER_EXTERNAL_ID="$WG_PEER_EXTERNAL_ID"
WG_PEER_DESCRIPTION="$WG_PEER_DESCRIPTION"
EOF

  echo "Environment file created: $ENV_FILE"
  echo ""
}

# Generate a self-signed TLS certificate for the Keycloak nginx proxy.
# The cert is written to config/nginx/ssl/ and mounted read-only into the
# keycloak-proxy container.  Skipped on re-runs when the cert already exists.
generate_keycloak_tls_cert() {
  echo "============================================"
  echo "  Generating Keycloak TLS Certificate"
  echo "============================================"
  echo ""

  local ssl_dir="$PROJECT_DIR/config/nginx/ssl"
  mkdir -p "$ssl_dir"

  if [ -f "$ssl_dir/server.crt" ] && [ -f "$ssl_dir/server.key" ]; then
    echo "TLS certificate already exists, skipping generation."
    echo ""
    return
  fi

  # Extract hostname/IP from KEYCLOAK_PUBLIC_URL (strip scheme and port)
  local kc_host
  kc_host=$(echo "$KEYCLOAK_PUBLIC_URL" | sed 's|https\?://||' | cut -d: -f1 | cut -d/ -f1)

  openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
    -keyout "$ssl_dir/server.key" \
    -out    "$ssl_dir/server.crt" \
    -subj   "/CN=${kc_host}/O=Stargate" 2>/dev/null

  chmod 600 "$ssl_dir/server.key"
  echo "TLS certificate generated: $ssl_dir/server.crt"
  echo "  CN: $kc_host  |  Valid: 10 years"
  echo ""
}

# Render config/keycloak/realm-stargate.json template into config/keycloak/generated/
# by substituting the two client-secret placeholders with the values from the
# customer config.  Keycloak does not resolve ${env.VAR} syntax at import time,
# so the substitution must happen before the container starts.
generate_keycloak_realm() {
  echo "============================================"
  echo "  Generating Keycloak Realm Config"
  echo "============================================"
  echo ""

  local out_dir="$PROJECT_DIR/config/keycloak/generated"
  mkdir -p "$out_dir"

  sed \
    -e "s|\${KEYCLOAK_APISIX_CLIENT_SECRET}|${KEYCLOAK_APISIX_CLIENT_SECRET}|g" \
    -e "s|\${KEYCLOAK_DASHBOARD_CLIENT_SECRET}|${KEYCLOAK_DASHBOARD_CLIENT_SECRET}|g" \
    -e "s|\${DASHBOARD_PUBLIC_URL}|${DASHBOARD_PUBLIC_URL}|g" \
    "$PROJECT_DIR/config/keycloak/realm-stargate.json" \
    > "$out_dir/realm-stargate.json"

  echo "Keycloak realm config generated: $out_dir/realm-stargate.json"
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

# Generate self-signed TLS cert for the Keycloak nginx proxy
generate_keycloak_tls_cert

# Generate Keycloak realm JSON with actual client secrets substituted in
generate_keycloak_realm

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
  
  # Run onboarding (S/MIME key + CSR generation, .env domain updates)
  echo ""
  ONBOARD_EXIT=0
  "$SCRIPT_DIR/onboard.sh" --initial-setup || ONBOARD_EXIT=$?
  
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
if [ "${ONBOARD_EXIT:-0}" -eq 0 ]; then
  echo "============================================"
  echo "  Installation Complete!"
  echo "============================================"
else
  echo "============================================"
  echo "  Installation Complete (with warnings)"
  echo "============================================"
  echo ""
  echo "  ⚠ Certificate issuance failed."
  echo "    The WireGuard tunnel to the CA is not yet established."
  echo "    Services are running — the certificate can be retried with:"
  echo "      ./scripts/onboard.sh --regenerate-cert"
fi
echo ""
echo "  Customer: $CUSTOMER_NAME"
echo "  Deployment: $DEPLOYMENT_NAME"
echo ""
echo "  Dashboard:"
echo "  ----------"
echo "  URL:               $DASHBOARD_PUBLIC_URL"
echo ""
echo "  Keycloak Admin Console:"
echo "  -----------------------"
echo "  URL:               $KEYCLOAK_PUBLIC_URL/admin"
echo "  Username:          $KEYCLOAK_ADMIN_USER"
echo "  Password:          $KEYCLOAK_ADMIN_PASSWORD"
echo "  (You will be prompted to change the password on first login)"
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

# ============================================
# HIN WireGuard Peer Registration block
# ============================================
# Print the values HIN needs to register this Stargate as a WireGuard peer.
# Without this registration the WG tunnel cannot be established and S/MIME
# certificate issuance will keep failing.

WG_PUBKEY_FOR_HIN="$(docker compose logs idagent 2>/dev/null \
  | grep -m1 'wireguard public key:' \
  | sed 's/.*wireguard public key: //' \
  | tr -d '[:space:]')"

echo "============================================"
echo "  HIN WireGuard Peer Registration"
echo "============================================"
echo ""
echo "  Send the following values to HIN (aroel.vandenbroele@hin.ch)"
echo "  so they can register this Stargate as a WireGuard peer."
echo "  Until the peer is registered, S/MIME cert issuance will fail."
echo ""
echo "  WireGuard Public Key: ${WG_PUBKEY_FOR_HIN:-<not yet available - run: docker compose logs idagent | grep \"wireguard public key\">}"
echo "  DEPLOYMENT_NAME:      $DEPLOYMENT_NAME"
echo "  SERVER_STATIC_IP:     $SERVER_STATIC_IP"
echo "  WG_INTERFACE_PORT:    $WG_INTERFACE_PORT"
echo ""
echo "  After HIN confirms registration, run:"
echo "    ./scripts/onboard.sh --regenerate-cert"
echo ""
echo "  Recommended next steps:"
echo "    - SPF / DKIM / DMARC for your sending domains"
echo "      (see README.md → 'Post-Onboarding Recommendations')"
echo "    - Microsoft 365 / Exchange Online relay-back connectors"
echo "      (see Exchange-integration.md)"
echo ""
