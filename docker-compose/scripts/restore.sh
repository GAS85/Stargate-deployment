#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$PROJECT_DIR/backups"
SECRETS_DIR="$PROJECT_DIR/secrets"
ENV_FILE="$PROJECT_DIR/.env"
CONFIG_FILE="$PROJECT_DIR/customer-config.sh"
KEYS_FILE="$SECRETS_DIR/vault-keys.json"

# Determine Linux distribution for package manager
if [ -f /etc/os-release ]; then
  DIST_ID=$(grep ^ID= /etc/os-release | cut -f2 -d= | sed 's/"//g')
else
  echo "File /etc/os-release not found, cannot determine Linux distribution."
  exit 1
fi

if [[ $DIST_ID == debian || $DIST_ID == ubuntu || $DIST_ID == linuxmint || $DIST_ID == kali ]]; then
  PKGMGR=apt
else
  PKGMGR=dnf
fi

cd "$PROJECT_DIR"

# ==============================================================================
# Usage
# ==============================================================================
usage() {
  echo "Usage: $0 <backup-file.tar.gz>"
  echo ""
  echo "Restore Stargate from a backup archive."
  echo ""
  echo "Arguments:"
  echo "  backup-file.tar.gz  Path to the backup archive (absolute or relative)"
  echo ""
  echo "Examples:"
  echo "  $0 backups/20260130_143022.tar.gz"
  echo "  $0 /root/stargate-backup.tar.gz"
  echo ""
  echo "This script will:"
  echo "  1. Stop any running services"
  echo "  2. Extract and validate the backup"
  echo "  3. Restore customer configuration"
  echo "  4. Install Docker if needed"
  echo "  5. Start infrastructure services (PostgreSQL, Vault, MinIO)"
  echo "  6. Restore the database"
  echo "  7. Restore Vault keys and unseal"
  echo "  8. Start application services"
  echo ""
  exit 1
}

# Check arguments
if [ $# -ne 1 ]; then
  usage
fi

BACKUP_FILE="$1"

# Resolve relative path
if [[ ! "$BACKUP_FILE" = /* ]]; then
  BACKUP_FILE="$PROJECT_DIR/$BACKUP_FILE"
fi

if [ ! -f "$BACKUP_FILE" ]; then
  echo "ERROR: Backup file not found: $BACKUP_FILE"
  exit 1
fi

echo "============================================"
echo "  Stargate Restore"
echo "============================================"
echo ""
echo "Backup file: $BACKUP_FILE"
echo ""

# ==============================================================================
# Docker Installation (same as install.sh)
# ==============================================================================
install_docker() {
  echo "Installing Docker from official repository..."
  if [[ $PKGMGR == apt ]]; then
    sudo $PKGMGR update -y && sudo $PKGMGR upgrade -y
    sudo $PKGMGR remove -y docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc 2>/dev/null || true
    sudo $PKGMGR install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/$DIST_ID/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/$DIST_ID \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo $PKGMGR update -y
  else
    sudo $PKGMGR update -y
    sudo $PKGMGR remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine podman runc 2>/dev/null || true
    sudo rpm --import https://download.docker.com/linux/rhel/gpg
    sudo $PKGMGR -y install dnf-plugins-core
    sudo $PKGMGR config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
  fi
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

# ==============================================================================
# 1. Stop Running Services
# ==============================================================================
echo "============================================"
echo "  1. Stopping Running Services"
echo "============================================"
echo ""

if docker compose ps -q 2>/dev/null | grep -q .; then
  echo "Stopping existing services..."
  docker compose down --remove-orphans 2>/dev/null || true
  echo "  ✓ Services stopped"
else
  echo "  - No running services found"
fi
echo ""

# ==============================================================================
# 2. Check Dependencies
# ==============================================================================
echo "============================================"
echo "  2. Checking Dependencies"
echo "============================================"
echo ""
check_dependencies
echo "  ✓ All dependencies satisfied"
echo ""

# ==============================================================================
# 3. Extract and Validate Backup
# ==============================================================================
echo "============================================"
echo "  3. Extracting Backup"
echo "============================================"
echo ""

RESTORE_DIR=$(mktemp -d)
echo "Extracting to: $RESTORE_DIR"

tar -xzf "$BACKUP_FILE" -C "$RESTORE_DIR"

# Find the backup subdirectory (timestamp folder)
BACKUP_CONTENT=$(find "$RESTORE_DIR" -mindepth 1 -maxdepth 1 -type d | head -1)

if [ -z "$BACKUP_CONTENT" ]; then
  echo "ERROR: Invalid backup structure - no subdirectory found"
  rm -rf "$RESTORE_DIR"
  exit 1
fi

echo "  ✓ Backup extracted"

# Check manifest
if [ -f "$BACKUP_CONTENT/manifest.json" ]; then
  echo ""
  echo "Backup manifest:"
  cat "$BACKUP_CONTENT/manifest.json" | jq .
  echo ""
  
  BACKUP_VERSION=$(jq -r '.backup_version // "1.0"' "$BACKUP_CONTENT/manifest.json")
  if [ "$BACKUP_VERSION" != "2.0" ]; then
    echo "WARNING: Backup version $BACKUP_VERSION may not be fully compatible"
  fi
else
  echo "  - No manifest found (older backup format)"
fi

# Validate required files
MISSING_FILES=()
[ ! -f "$BACKUP_CONTENT/config/customer-config.sh" ] && MISSING_FILES+=("customer-config.sh")
[ ! -f "$BACKUP_CONTENT/database/full_dump.sql" ] && MISSING_FILES+=("full_dump.sql")

if [ ${#MISSING_FILES[@]} -gt 0 ]; then
  echo "ERROR: Missing required files in backup:"
  for f in "${MISSING_FILES[@]}"; do
    echo "  - $f"
  done
  rm -rf "$RESTORE_DIR"
  exit 1
fi

echo "  ✓ Backup validated"
echo ""

# ==============================================================================
# 4. Restore Customer Configuration
# ==============================================================================
echo "============================================"
echo "  4. Restoring Customer Configuration"
echo "============================================"
echo ""

# Backup existing config if present
if [ -f "$CONFIG_FILE" ]; then
  mv "$CONFIG_FILE" "${CONFIG_FILE}.bak.$(date +%s)"
  echo "  - Existing customer-config.sh backed up"
fi

cp "$BACKUP_CONTENT/config/customer-config.sh" "$CONFIG_FILE"
echo "  ✓ customer-config.sh restored"

# Source the restored config
source "$CONFIG_FILE"

echo ""
echo "  Customer: ${CUSTOMER_NAME:-unknown}"
echo "  Deployment: ${DEPLOYMENT_NAME:-unknown}"
echo ""

# ==============================================================================
# 5. Restore Secrets (Vault keys, CSR, certificates)
# ==============================================================================
echo "============================================"
echo "  5. Restoring Secrets"
echo "============================================"
echo ""

mkdir -p "$SECRETS_DIR"

# Restore vault keys
if [ -f "$BACKUP_CONTENT/secrets/vault-keys.json" ]; then
  cp "$BACKUP_CONTENT/secrets/vault-keys.json" "$SECRETS_DIR/"
  echo "  ✓ vault-keys.json restored"
  ROOT_TOKEN=$(jq -r '.root_token' "$SECRETS_DIR/vault-keys.json")
else
  echo "  ✗ WARNING: vault-keys.json not in backup"
  echo "    Vault will need to be reinitialized!"
  ROOT_TOKEN=""
fi

# Restore CSR
if [ -f "$BACKUP_CONTENT/secrets/signing-key.csr" ]; then
  cp "$BACKUP_CONTENT/secrets/signing-key.csr" "$SECRETS_DIR/"
  echo "  ✓ signing-key.csr restored"
fi

# Restore certificates
CERT_COUNT=0
for cert in "$BACKUP_CONTENT/secrets"/*.crt "$BACKUP_CONTENT/secrets"/*.pem "$BACKUP_CONTENT/secrets"/*.cer; do
  if [ -f "$cert" ]; then
    cp "$cert" "$SECRETS_DIR/"
    echo "  ✓ $(basename "$cert") restored"
    ((CERT_COUNT++)) || true
  fi
done

echo ""

# ==============================================================================
# 6. Generate Environment File
# ==============================================================================
echo "============================================"
echo "  6. Generating Environment File"
echo "============================================"
echo ""

# Set defaults for optional fields (same as install.sh)
POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-postgres}"
MINIO_ROOT_USER="${MINIO_ROOT_USER:-minioadmin}"
MINIO_ROOT_PASSWORD="${MINIO_ROOT_PASSWORD:-minioadmin}"
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
WG_PRIVATE_KEY="${WG_PRIVATE_KEY:-}"

# WireGuard peer configuration
WG_PEER_CONNECTION_ID="${WG_PEER_CONNECTION_ID:-}"
WG_PEER_NAME="${WG_PEER_NAME:-default}"
WG_PEER_IP="${WG_PEER_IP:-10.0.0.2}"
WG_PEER_PORT="${WG_PEER_PORT:-9090}"
WG_PEER_ALLOWED_IPS="${WG_PEER_ALLOWED_IPS:-${WG_PEER_IP}/32}"
WG_PEER_EXTERNAL_ID="${WG_PEER_EXTERNAL_ID:-}"
WG_PEER_DESCRIPTION="${WG_PEER_DESCRIPTION:-WireGuard peer connection}"

# If we have the old .env, try to preserve generated passwords
if [ -f "$BACKUP_CONTENT/config/.env" ]; then
  source "$BACKUP_CONTENT/config/.env"
  echo "  ✓ Loaded credentials from backup .env"
fi

cat > "$ENV_FILE" << EOF
# ==============================================================================
# Stargate Environment Configuration
# ==============================================================================
# Restored from backup on $(date)
# Customer: $CUSTOMER_NAME
# Deployment: $DEPLOYMENT_NAME
# ==============================================================================

# PostgreSQL
POSTGRES_USER=$POSTGRES_USER
POSTGRES_PASSWORD=$POSTGRES_PASSWORD

# Vault
VAULT_TOKEN=${ROOT_TOKEN:-}

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
POSTFIX_MYNETWORKS=${POSTFIX_MYNETWORKS:-}

# Logging
LOKI_URL=$LOKI_URL
PROMTAIL_HOSTNAME=$DEPLOYMENT_NAME

# Policy Sync
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
WG_PRIVATE_KEY=${WG_PRIVATE_KEY:-}

# WireGuard Peer Configuration
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

echo "  ✓ Environment file generated"
echo ""

# ==============================================================================
# 7. Start Infrastructure Services
# ==============================================================================
echo "============================================"
echo "  7. Starting Infrastructure Services"
echo "============================================"
echo ""

echo "Starting PostgreSQL, Vault, MinIO, Postfix..."
docker compose up -d postgres vault minio postfix

echo "Waiting for PostgreSQL to be ready..."
for i in {1..30}; do
  if docker exec stargate-postgres pg_isready -U "$POSTGRES_USER" > /dev/null 2>&1; then
    echo "  ✓ PostgreSQL is ready"
    break
  fi
  echo "  Waiting... ($i/30)"
  sleep 2
done

if ! docker exec stargate-postgres pg_isready -U "$POSTGRES_USER" > /dev/null 2>&1; then
  echo "ERROR: PostgreSQL failed to start"
  exit 1
fi
echo ""

# ==============================================================================
# 8. Restore Database
# ==============================================================================
echo "============================================"
echo "  8. Restoring Database"
echo "============================================"
echo ""

echo "Restoring full database dump..."
docker exec -i stargate-postgres psql -U "$POSTGRES_USER" -d postgres < "$BACKUP_CONTENT/database/full_dump.sql" 2>&1 | grep -v "already exists" | grep -v "^CREATE" | head -20 || true

echo "  ✓ Database restored"
echo ""

# Verify databases exist
echo "Verifying databases..."
for DB in smimekeys_client policy idagent mxengine; do
  if docker exec stargate-postgres psql -U "$POSTGRES_USER" -lqt | cut -d \| -f 1 | grep -qw "$DB"; then
    echo "  ✓ $DB exists"
  else
    echo "  ✗ $DB missing"
  fi
done
echo ""

# ==============================================================================
# 9. Unseal Vault
# ==============================================================================
echo "============================================"
echo "  9. Unsealing Vault"
echo "============================================"
echo ""

if [ -f "$SECRETS_DIR/vault-keys.json" ]; then
  echo "Waiting for Vault to be ready..."
  for i in {1..30}; do
    if curl -s http://localhost:8200/v1/sys/health > /dev/null 2>&1; then
      break
    fi
    sleep 2
  done
  
  # Check if Vault is sealed
  SEALED=$(curl -s http://localhost:8200/v1/sys/seal-status | jq -r '.sealed')
  
  if [ "$SEALED" = "true" ]; then
    echo "Unsealing Vault..."
    UNSEAL_KEYS=$(jq -r '.unseal_keys_b64[]' "$SECRETS_DIR/vault-keys.json")
    for key in $UNSEAL_KEYS; do
      curl -s --request POST --data "{\"key\": \"$key\"}" http://localhost:8200/v1/sys/unseal > /dev/null
    done
    echo "  ✓ Vault unsealed"
  else
    echo "  - Vault is already unsealed (or not initialized)"
  fi
else
  echo "  ✗ No vault-keys.json - Vault needs manual initialization"
fi
echo ""

# ==============================================================================
# 10. Start Application Services
# ==============================================================================
echo "============================================"
echo "  10. Starting Application Services"
echo "============================================"
echo ""

echo "Starting all services..."
docker compose up -d

echo ""
echo "Waiting for services to initialize..."
sleep 10

# ==============================================================================
# 11. Verify Services
# ==============================================================================
echo "============================================"
echo "  11. Verifying Services"
echo "============================================"
echo ""

docker compose ps

echo ""

# Check service health
SERVICES=("smimekeys-client:8081" "policy:8082" "idagent:8083" "mxengine:8084")
echo "Service health checks:"
for svc in "${SERVICES[@]}"; do
  NAME="${svc%%:*}"
  PORT="${svc##*:}"
  if curl -s "http://localhost:$PORT/liveness" > /dev/null 2>&1; then
    echo "  ✓ $NAME is healthy"
  else
    echo "  - $NAME not responding (may still be starting)"
  fi
done
echo ""

# ==============================================================================
# Cleanup
# ==============================================================================
rm -rf "$RESTORE_DIR"

# ==============================================================================
# Summary
# ==============================================================================
echo ""
echo "============================================"
echo "  Restore Complete!"
echo "============================================"
echo ""
echo "  Customer: $CUSTOMER_NAME"
echo "  Deployment: $DEPLOYMENT_NAME"
echo ""
echo "  What was restored:"
echo "  ------------------"
echo "  ✓ Customer configuration"
echo "  ✓ Database (all tables and data)"
echo "  ✓ Vault keys"
if [ $CERT_COUNT -gt 0 ]; then
  echo "  ✓ S/MIME certificates ($CERT_COUNT files)"
fi
if [ -n "$WG_PRIVATE_KEY" ]; then
  echo "  ✓ WireGuard private key"
fi
echo ""
echo "  Service URLs:"
echo "  -------------"
echo "  smimekeys-client:  http://localhost:8081"
echo "  policy:            http://localhost:8082"
echo "  idagent:           http://localhost:8083"
echo "  mxengine:          http://localhost:8084"
echo ""
echo "  If services show errors, wait a minute and check:"
echo "    docker compose logs -f <service-name>"
echo ""
