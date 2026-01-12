#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SECRETS_DIR="$PROJECT_DIR/secrets"
KEYS_FILE="$SECRETS_DIR/vault-keys.json"
ENV_FILE="$PROJECT_DIR/.env"

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

# Function to install Docker on Ubuntu
install_docker() {
  echo "Installing Docker from official repository..."
  
  # Remove old packages
  sudo apt remove -y docker.io docker-doc docker-compose podman-docker containerd runc 2>/dev/null || true
  
  # Install prerequisites
  sudo apt update
  sudo apt install -y ca-certificates curl
  
  # Add Docker's official GPG key
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  
  # Add the repository
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  
  # Install Docker
  sudo apt update
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin jq
  
  echo "Docker installed successfully!"
  docker --version
  docker compose version
}

# Check for required commands
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
    read -p "Do you want to install Docker and dependencies? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      install_docker
    else
      echo "Please install the missing dependencies and try again."
      exit 1
    fi
  fi
}

# Function to update .env file with vault token
update_env_token() {
  local token="$1"
  if grep -q "^VAULT_TOKEN=" "$ENV_FILE"; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "s/^VAULT_TOKEN=.*/VAULT_TOKEN=$token/" "$ENV_FILE"
    else
      sed -i "s/^VAULT_TOKEN=.*/VAULT_TOKEN=$token/" "$ENV_FILE"
    fi
  else
    echo "VAULT_TOKEN=$token" >> "$ENV_FILE"
  fi
  echo "Updated VAULT_TOKEN in .env file"
}

# Function to generate S/MIME key and CSR
generate_smime_key_and_csr() {
  echo ""
  echo "============================================"
  echo "  S/MIME Key and CSR Generation"
  echo "============================================"
  echo ""
  echo "This will generate a signing key and CSR for the smimekeys service."
  echo "Press Enter to accept default values shown in [brackets]."
  echo ""
  
  # Prompt for configuration values
  read -p "DNS Names (comma-separated) [domain.com]: " input_dns_names
  DNS_NAMES="${input_dns_names:-domain.com}"
  
  read -p "Subject Organization [Vereign AG - alpha]: " input_subject_org
  SUBJECT_ORG="${input_subject_org:-Vereign AG - alpha}"
  
  read -p "Subject Common Name [Vereign AG - alpha]: " input_subject_cn
  SUBJECT_CN="${input_subject_cn:-Vereign AG - alpha}"
  
  read -p "Subject Countries (comma-separated) [CH,BG]: " input_subject_country
  SUBJECT_COUNTRY="${input_subject_country:-CH,BG}"
  
  # Convert comma-separated DNS names to JSON array
  DNS_NAMES_JSON=$(echo "$DNS_NAMES" | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | jq -R . | jq -s .)
  
  # Convert comma-separated countries to JSON array
  COUNTRY_JSON=$(echo "$SUBJECT_COUNTRY" | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | jq -R . | jq -s .)
  
  echo ""
  echo "Generating key with smimekeys-client..."
  
  # Wait for smimekeys-client to be ready
  for i in {1..30}; do
    if curl -s http://localhost:8081/liveness > /dev/null 2>&1; then
      break
    fi
    echo "Waiting for smimekeys-client to be ready... ($i/30)"
    sleep 2
  done
  
  # Step 1: Generate key
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
      \"subjectCN\": \"$SUBJECT_CN\",
      \"subjectCountry\": $COUNTRY_JSON,
      \"subjectOrg\": \"$SUBJECT_ORG\"
    }")
  
  echo ""
  echo "============================================"
  echo "  CSR Generated Successfully"
  echo "============================================"
  echo ""
  echo "$CSR_RESPONSE" | jq . 2>/dev/null || echo "$CSR_RESPONSE"
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

# ============================================
# Main Installation
# ============================================

# Check dependencies first
check_dependencies

# Create directories
mkdir -p "$SECRETS_DIR"
mkdir -p "$PROJECT_DIR/backups"

# Create .env file
if [ ! -f "$ENV_FILE" ]; then
  if [ -f "$PROJECT_DIR/.env.example" ]; then
    echo "Creating .env file from .env.example..."
    cp "$PROJECT_DIR/.env.example" "$ENV_FILE"
  else
    echo "Creating default .env file..."
    cat > "$ENV_FILE" << 'EOF'
# PostgreSQL
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres

# Vault (auto-populated by install.sh)
VAULT_TOKEN=

# MinIO (S3)
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin123
S3_BUCKET_NAME=svdh-bucket

# Application Versions
SMIMEKEYS_VERSION=latest
POLICY_VERSION=latest
IDAGENT_VERSION=latest
MXENGINE_VERSION=latest

# Postfix Relay (auto-configures from DNS)
MAIL_DOMAIN=

# Logging (Promtail -> Loki)
LOKI_URL=https://loki.k8s.vereign-cdn.com
PROMTAIL_HOSTNAME=stargate
EOF
  fi
fi

# Prompt for required configuration if not set
configure_required_settings() {
  echo ""
  echo "============================================"
  echo "  Configuration"
  echo "============================================"
  echo ""
  
  # Check MAIL_DOMAIN
  CURRENT_MAIL_DOMAIN=$(grep "^MAIL_DOMAIN=" "$ENV_FILE" | cut -d'=' -f2-)
  if [ -z "$CURRENT_MAIL_DOMAIN" ]; then
    read -p "Mail domain for Postfix relay (e.g., example.com): " input_mail_domain
    if [ -n "$input_mail_domain" ]; then
      sed -i "s/^MAIL_DOMAIN=.*/MAIL_DOMAIN=$input_mail_domain/" "$ENV_FILE"
      echo "Set MAIL_DOMAIN=$input_mail_domain"
    else
      echo "WARNING: MAIL_DOMAIN not set. Postfix relay will not start."
    fi
  fi
  
  # Check PROMTAIL_HOSTNAME
  CURRENT_HOSTNAME=$(grep "^PROMTAIL_HOSTNAME=" "$ENV_FILE" | cut -d'=' -f2-)
  if [ "$CURRENT_HOSTNAME" = "stargate" ] || [ -z "$CURRENT_HOSTNAME" ]; then
    SUGGESTED_HOSTNAME=$(hostname -s 2>/dev/null || echo "stargate")
    read -p "Hostname for log labels [$SUGGESTED_HOSTNAME]: " input_hostname
    PROMTAIL_HOSTNAME="${input_hostname:-$SUGGESTED_HOSTNAME}"
    if grep -q "^PROMTAIL_HOSTNAME=" "$ENV_FILE"; then
      sed -i "s/^PROMTAIL_HOSTNAME=.*/PROMTAIL_HOSTNAME=$PROMTAIL_HOSTNAME/" "$ENV_FILE"
    else
      echo "PROMTAIL_HOSTNAME=$PROMTAIL_HOSTNAME" >> "$ENV_FILE"
    fi
    echo "Set PROMTAIL_HOSTNAME=$PROMTAIL_HOSTNAME"
  fi
  
  echo ""
}

configure_required_settings

# Check Docker registry access
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
echo "  Promtail:          Logs -> Loki"
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
