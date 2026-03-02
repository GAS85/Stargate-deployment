#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SECRETS_DIR="$PROJECT_DIR/secrets"
ENV_FILE="$PROJECT_DIR/.env"
CONFIG_FILE="$PROJECT_DIR/customer-config.sh"
CSR_FILE="$SECRETS_DIR/signing-key.csr"

cd "$PROJECT_DIR"

# ==============================================================================
# Parse Flags
# ==============================================================================

REGENERATE_CERT=false
INITIAL_SETUP=false  # Set when called from install.sh

for arg in "$@"; do
  case $arg in
    --regenerate-cert) REGENERATE_CERT=true ;;
    --initial-setup) INITIAL_SETUP=true ;;
    --help|-h)
      echo "Usage: ./scripts/onboard.sh [OPTIONS]"
      echo ""
      echo "Configure mail domains, S/MIME certificates, and WireGuard peers."
      echo "Reads configuration from customer-config.sh and applies changes."
      echo ""
      echo "Options:"
      echo "  --regenerate-cert   Force regeneration of S/MIME signing key and CSR"
      echo "  --initial-setup     Called by install.sh (skip service checks and restarts)"
      echo "  --help, -h          Show this help message"
      echo ""
      echo "Workflow:"
      echo "  1. Edit customer-config.sh (add/change MAIL_DOMAINS, WG peer settings, etc.)"
      echo "  2. Run: ./scripts/onboard.sh"
      echo ""
      echo "Examples:"
      echo "  # Add a new mail domain:"
      echo "  #   Edit customer-config.sh: MAIL_DOMAINS=\"example.com,newdomain.com\""
      echo "  ./scripts/onboard.sh"
      echo ""
      echo "  # Regenerate S/MIME certificate (e.g., after changing CERT_DNS_NAMES):"
      echo "  ./scripts/onboard.sh --regenerate-cert"
      exit 0
      ;;
  esac
done

echo "============================================"
echo "  Stargate - Domain Onboarding"
echo "============================================"
echo ""

# ==============================================================================
# Helpers
# ==============================================================================

# Generate UUID v7 (time-ordered UUID)
generate_uuid7() {
  local ts_ms=$(date +%s%3N)
  local ts_hex=$(printf '%012x' "$ts_ms")
  local rand=$(head -c 10 /dev/urandom | od -An -tx1 | tr -d ' \n')
  local time_high="${ts_hex:0:8}"
  local time_mid="${ts_hex:8:4}"
  local rand_a="${rand:0:3}"
  local variant_byte=$((0x80 | (0x${rand:3:2} & 0x3f)))
  local variant_hex=$(printf '%02x' "$variant_byte")
  local rand_b="${rand:5:2}"
  local rand_c="${rand:7:12}"
  echo "${time_high}-${time_mid}-7${rand_a}-${variant_hex}${rand_b}-${rand_c}"
}

# Update a single variable in the .env file
update_env_var() {
  local key="$1"
  local value="$2"
  if grep -q "^${key}=" "$ENV_FILE"; then
    sed -i "s|^${key}=.*|${key}=${value}|" "$ENV_FILE"
  else
    echo "${key}=${value}" >> "$ENV_FILE"
  fi
}

# ==============================================================================
# Service Checks
# ==============================================================================

check_services() {
  if ! docker compose ps --format '{{.Name}}' 2>/dev/null | grep -q stargate; then
    echo "ERROR: Stargate services are not running."
    echo "Start them first: ./scripts/start.sh"
    exit 1
  fi
}

# ==============================================================================
# Load Configuration
# ==============================================================================

load_onboard_config() {
  if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Customer configuration file not found: $CONFIG_FILE"
    exit 1
  fi

  source "$CONFIG_FILE"

  # Multi-domain support: MAIL_DOMAINS takes precedence, fall back to MAIL_DOMAIN
  if [ -n "$MAIL_DOMAINS" ]; then
    MAIL_DOMAIN_PRIMARY=$(echo "$MAIL_DOMAINS" | cut -d',' -f1 | tr -d ' ')
  elif [ -n "$MAIL_DOMAIN" ]; then
    # Backward compatibility: single MAIL_DOMAIN
    MAIL_DOMAINS="$MAIL_DOMAIN"
    MAIL_DOMAIN_PRIMARY="$MAIL_DOMAIN"
  fi

  # Validate required fields
  local missing=()

  [ -z "$MAIL_DOMAINS" ] && missing+=("MAIL_DOMAINS (or MAIL_DOMAIN)")

  # Cert fields required for S/MIME key generation
  [ -z "$CERT_DNS_NAMES" ] && missing+=("CERT_DNS_NAMES")
  [ -z "$CERT_ORGANIZATION" ] && missing+=("CERT_ORGANIZATION")
  [ -z "$CERT_COMMON_NAME" ] && missing+=("CERT_COMMON_NAME")
  [ -z "$CERT_COUNTRIES" ] && missing+=("CERT_COUNTRIES")

  if [ ${#missing[@]} -gt 0 ]; then
    echo "ERROR: Missing required configuration values:"
    for f in "${missing[@]}"; do echo "  - $f"; done
    echo ""
    echo "Please fill in all required fields in:"
    echo "  $CONFIG_FILE"
    exit 1
  fi

  # Set defaults
  MAIL_HOSTNAME="${MAIL_HOSTNAME:-mail.${MAIL_DOMAIN_PRIMARY}}"
  OUTBOUND_SEALER_MX_DOMAIN="${OUTBOUND_SEALER_MX_DOMAIN:-}"
  CERT_CA_IDAGENT_DOMAIN="${CERT_CA_IDAGENT_DOMAIN:-}"
  OUTBOUND_SMTP_HOST="${OUTBOUND_SMTP_HOST:-postfix-relay}"
  OUTBOUND_SMTP_PORT="${OUTBOUND_SMTP_PORT:-10026}"

  # WireGuard peer defaults
  WG_LOCAL_IP="${WG_LOCAL_IP:-10.0.0.1}"
  WG_INTERFACE_PORT="${WG_INTERFACE_PORT:-19818}"
  WG_TRANSPORT_MODE="${WG_TRANSPORT_MODE:-tcp}"
  WG_PEER_CONNECTION_ID="${WG_PEER_CONNECTION_ID:-}"
  WG_PEER_NAME="${WG_PEER_NAME:-default}"
  WG_PEER_PUBLIC_KEY="${WG_PEER_PUBLIC_KEY:-}"
  WG_PEER_ENDPOINT="${WG_PEER_ENDPOINT:-}"
  WG_PEER_IP="${WG_PEER_IP:-10.0.0.2}"
  WG_PEER_PORT="${WG_PEER_PORT:-9090}"
  WG_PEER_ALLOWED_IPS="${WG_PEER_ALLOWED_IPS:-${WG_PEER_IP}/32}"
  WG_PEER_EXTERNAL_ID="${WG_PEER_EXTERNAL_ID:-}"
  WG_PEER_DESCRIPTION="${WG_PEER_DESCRIPTION:-WireGuard peer connection}"

  # Generate UUID v7 for connection if not provided
  if [ -n "$WG_PEER_PUBLIC_KEY" ] && [ -z "$WG_PEER_CONNECTION_ID" ]; then
    WG_PEER_CONNECTION_ID="$(generate_uuid7)"
  fi

  echo "Configuration:"
  echo "  Mail domains:    $MAIL_DOMAINS"
  echo "  Mail hostname:   $MAIL_HOSTNAME"
  echo "  Cert DNS names:  $CERT_DNS_NAMES"
  echo "  Cert org:        $CERT_ORGANIZATION"
  if [ -n "$WG_PEER_ENDPOINT" ]; then
    echo "  WG peer:         $WG_PEER_NAME ($WG_PEER_ENDPOINT)"
  fi
  echo ""
}

# ==============================================================================
# Update .env File
# ==============================================================================

update_env_settings() {
  echo "Updating .env file..."

  # Migrate MAIL_DOMAIN → MAIL_DOMAINS if needed
  if grep -q "^MAIL_DOMAIN=" "$ENV_FILE" && ! grep -q "^MAIL_DOMAINS=" "$ENV_FILE"; then
    sed -i "s|^MAIL_DOMAIN=.*|MAIL_DOMAINS=${MAIL_DOMAINS}|" "$ENV_FILE"
  else
    update_env_var "MAIL_DOMAINS" "$MAIL_DOMAINS"
  fi

  update_env_var "MAIL_HOSTNAME" "$MAIL_HOSTNAME"
  update_env_var "OUTBOUND_SEALER_MX_DOMAIN" "${OUTBOUND_SEALER_MX_DOMAIN}"
  update_env_var "CERT_CA_IDAGENT_DOMAIN" "${CERT_CA_IDAGENT_DOMAIN}"
  update_env_var "OUTBOUND_SMTP_HOST" "$OUTBOUND_SMTP_HOST"
  update_env_var "OUTBOUND_SMTP_PORT" "$OUTBOUND_SMTP_PORT"

  # WireGuard settings
  update_env_var "WG_LOCAL_IP" "$WG_LOCAL_IP"
  update_env_var "WG_INTERFACE_PORT" "$WG_INTERFACE_PORT"
  update_env_var "WG_TRANSPORT_MODE" "$WG_TRANSPORT_MODE"

  if [ -n "$WG_PEER_CONNECTION_ID" ]; then
    update_env_var "WG_PEER_CONNECTION_ID" "$WG_PEER_CONNECTION_ID"
  fi
  update_env_var "WG_PEER_NAME" "$WG_PEER_NAME"
  if [ -n "$WG_PEER_PUBLIC_KEY" ]; then
    update_env_var "WG_PEER_PUBLIC_KEY" "$WG_PEER_PUBLIC_KEY"
  fi
  if [ -n "$WG_PEER_ENDPOINT" ]; then
    update_env_var "WG_PEER_ENDPOINT" "$WG_PEER_ENDPOINT"
  fi
  update_env_var "WG_PEER_IP" "$WG_PEER_IP"
  update_env_var "WG_PEER_PORT" "$WG_PEER_PORT"
  update_env_var "WG_PEER_ALLOWED_IPS" "$WG_PEER_ALLOWED_IPS"
  update_env_var "WG_PEER_EXTERNAL_ID" "${WG_PEER_EXTERNAL_ID:-}"
  update_env_var "WG_PEER_DESCRIPTION" "$WG_PEER_DESCRIPTION"

  echo "  .env updated"
  echo ""
}

# ==============================================================================
# S/MIME Key and CSR Generation
# ==============================================================================

generate_smime_key_and_csr() {
  if [ -f "$CSR_FILE" ] && [ "$REGENERATE_CERT" = false ]; then
    echo "S/MIME signing key and CSR already exist."
    echo "  CSR: $CSR_FILE"
    echo "  Use --regenerate-cert to create a new one."
    echo ""
    return 0
  fi

  echo "============================================"
  echo "  S/MIME Key and CSR Generation"
  echo "============================================"
  echo ""
  echo "  DNS Names:    $CERT_DNS_NAMES"
  echo "  Organization: $CERT_ORGANIZATION"
  echo "  Common Name:  $CERT_COMMON_NAME"
  echo "  Countries:    $CERT_COUNTRIES"
  echo ""

  # Convert comma-separated values to JSON arrays
  DNS_NAMES_JSON=$(echo "$CERT_DNS_NAMES" | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | jq -R . | jq -s .)
  COUNTRY_JSON=$(echo "$CERT_COUNTRIES" | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | jq -R . | jq -s .)

  echo "Waiting for smimekeys-client to be ready..."
  for i in $(seq 1 30); do
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

  echo "  Key ID: $KEY_ID"

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
  mkdir -p "$SECRETS_DIR"
  echo "$CSR_RESPONSE" | jq -r '.csr // empty' > "$CSR_FILE" 2>/dev/null || true

  echo ""
  echo "============================================"
  echo "  CSR Generated Successfully"
  echo "============================================"
  echo ""
  echo "$CSR_RESPONSE" | jq . 2>/dev/null || echo "$CSR_RESPONSE"
  echo ""

  if [ -s "$CSR_FILE" ]; then
    echo "  CSR saved to: $CSR_FILE"
  fi
  echo ""
}

# ==============================================================================
# WireGuard Peer Setup
# ==============================================================================

setup_wireguard_peer() {
  if [ -z "$WG_PEER_PUBLIC_KEY" ] || [ -z "$WG_PEER_ENDPOINT" ]; then
    echo "WireGuard peer not configured (WG_PEER_PUBLIC_KEY or WG_PEER_ENDPOINT not set)."
    echo "Skipping WG peer setup."
    echo ""
    return 0
  fi

  echo "Setting up WireGuard peer connection..."
  echo "  Peer: $WG_PEER_NAME ($WG_PEER_ENDPOINT)"
  echo ""

  docker compose run --rm idagent-init

  echo ""
}

# ==============================================================================
# Restart Services
# ==============================================================================

restart_services() {
  echo "Restarting services to apply changes..."
  docker compose up -d --force-recreate postfix-relay mxengine
  echo "Services restarted."
  echo ""
}

# ==============================================================================
# Main
# ==============================================================================

if [ "$INITIAL_SETUP" = false ]; then
  check_services
fi

load_onboard_config
update_env_settings
generate_smime_key_and_csr

if [ "$INITIAL_SETUP" = false ]; then
  setup_wireguard_peer
  restart_services
fi

echo "============================================"
echo "  Onboarding Complete"
echo "============================================"
echo ""
echo "  Mail domains:  $MAIL_DOMAINS"
echo "  Mail hostname: $MAIL_HOSTNAME"
if [ -n "$WG_PEER_ENDPOINT" ]; then
  echo "  WG peer:       $WG_PEER_NAME ($WG_PEER_ENDPOINT)"
fi
echo ""
echo "  To add or change domains:"
echo "    1. Edit customer-config.sh (update MAIL_DOMAINS)"
echo "    2. Run: ./scripts/onboard.sh"
echo ""
echo "  To regenerate S/MIME certificate:"
echo "    ./scripts/onboard.sh --regenerate-cert"
echo ""
