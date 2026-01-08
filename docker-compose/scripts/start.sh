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

# Check dependencies first
check_dependencies

# Create secrets directory if it doesn't exist
mkdir -p "$SECRETS_DIR"

# Create .env file from .env.example if it doesn't exist
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

# Vault (auto-populated by start.sh)
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
EOF
  fi
fi

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
  
  docker exec stargate-vault vault operator unseal "$UNSEAL_KEY_1" || true
  docker exec stargate-vault vault operator unseal "$UNSEAL_KEY_2" || true
  docker exec stargate-vault vault operator unseal "$UNSEAL_KEY_3" || true
  
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
