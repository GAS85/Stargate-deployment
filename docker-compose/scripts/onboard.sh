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
    sed -i "s|^${key}=.*|${key}=\"${value}\"|" "$ENV_FILE"
  else
    echo "${key}=\"${value}\"" >> "$ENV_FILE"
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

  # Cert fields (CERT_DNS_NAMES, CERT_ORGANIZATION, CERT_COMMON_NAME are auto-derived after validation)
  [ -z "$CERT_COUNTRIES" ] && missing+=("CERT_COUNTRIES")
  [ -z "$CUSTOMER_NAME" ] && missing+=("CUSTOMER_NAME")

  if [ ${#missing[@]} -gt 0 ]; then
    echo "ERROR: Missing required configuration values:"
    for f in "${missing[@]}"; do echo "  - $f"; done
    echo ""
    echo "Please fill in all required fields in:"
    echo "  $CONFIG_FILE"
    exit 1
  fi

  # Auto-derive certificate fields if not explicitly set
  MAIL_HOSTNAME="${MAIL_HOSTNAME:-mail.${MAIL_DOMAIN_PRIMARY}}"
  if [ -z "$CERT_DNS_NAMES" ]; then
    CERT_DNS_NAMES="$MAIL_DOMAINS,$MAIL_HOSTNAME"
  fi
  CERT_ORGANIZATION="${CERT_ORGANIZATION:-$CUSTOMER_NAME}"
  CERT_COMMON_NAME="${CERT_COMMON_NAME:-$CUSTOMER_NAME Mail Signing}"

  # Set defaults
  OUTBOUND_SEALER_MX_DOMAIN="${OUTBOUND_SEALER_MX_DOMAIN:-}"
  CERT_CA_IDAGENT_DOMAIN="${CERT_CA_IDAGENT_DOMAIN:-}"
  OUTBOUND_SMTP_HOST="${OUTBOUND_SMTP_HOST:-postfix-relay}"
  OUTBOUND_SMTP_PORT="${OUTBOUND_SMTP_PORT:-10026}"
  DOMAIN_RELAY_MAP="${DOMAIN_RELAY_MAP:-}"

  # Derive WG_LOCAL_IP and MXENGINE_PUBLIC_ADDRESS from SERVER_STATIC_IP
  SERVER_STATIC_IP="${SERVER_STATIC_IP:-}"
  if [ -z "$SERVER_STATIC_IP" ] && [ -n "$WG_LOCAL_IP" ] && [ "$WG_LOCAL_IP" != "10.0.0.1" ]; then
    SERVER_STATIC_IP="$WG_LOCAL_IP"
  fi

  if [ -n "$SERVER_STATIC_IP" ]; then
    WG_LOCAL_IP="${WG_LOCAL_IP:-$SERVER_STATIC_IP}"
    MXENGINE_PUBLIC_ADDRESS="${MXENGINE_PUBLIC_ADDRESS:-http://${SERVER_STATIC_IP}:8084}"
  fi

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
  update_env_var "MXENGINE_PUBLIC_ADDRESS" "${MXENGINE_PUBLIC_ADDRESS}"
  update_env_var "OUTBOUND_SEALER_MX_DOMAIN" "${OUTBOUND_SEALER_MX_DOMAIN}"
  update_env_var "CERT_CA_IDAGENT_DOMAIN" "${CERT_CA_IDAGENT_DOMAIN}"
  update_env_var "OUTBOUND_SMTP_HOST" "$OUTBOUND_SMTP_HOST"
  update_env_var "OUTBOUND_SMTP_PORT" "$OUTBOUND_SMTP_PORT"
  update_env_var "DOMAIN_RELAY_MAP" "${DOMAIN_RELAY_MAP:-}"

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

  # Step 2: Generate CSR and request certificate
  echo "Generating CSR and requesting certificate (this may take up to 60s)..."

  local tmp_response="$SECRETS_DIR/.csr_response.tmp"
  mkdir -p "$SECRETS_DIR"

  local http_code
  http_code=$(curl -s -o "$tmp_response" -w '%{http_code}' --max-time 90 \
    --location 'http://localhost:8081/v1/certs/csr' \
    --header 'Content-Type: application/json' \
    --header 'Accept: application/json' \
    --data "{
      \"dnsNames\": $DNS_NAMES_JSON,
      \"keyId\": \"$KEY_ID\",
      \"subjectCN\": \"$CERT_COMMON_NAME\",
      \"subjectCountry\": $COUNTRY_JSON,
      \"subjectOrg\": \"$CERT_ORGANIZATION\"
    }") || true

  CSR_RESPONSE=$(cat "$tmp_response" 2>/dev/null || true)
  rm -f "$tmp_response"

  # Check for success: HTTP 2xx means the CA endpoint processed the request.
  # The response may contain a .csr field (CSR returned) or certificate fields
  # (cert was issued immediately by the CA) - both are success cases.
  if [[ "$http_code" =~ ^2 ]]; then
    CSR_VALUE=$(echo "$CSR_RESPONSE" | jq -r '.csr // empty' 2>/dev/null || true)

    if [ -n "$CSR_VALUE" ]; then
      echo "$CSR_VALUE" > "$CSR_FILE"
    else
      # Certificate was issued directly by the CA - save the response as marker
      echo "$CSR_RESPONSE" > "$CSR_FILE"
    fi

    echo ""
    echo "============================================"
    echo "  Certificate Request Successful"
    echo "============================================"
    echo ""
    echo "$CSR_RESPONSE" | jq . 2>/dev/null || echo "$CSR_RESPONSE"
    echo ""
    echo "  Key ID: $KEY_ID"
    echo "  Saved:  $CSR_FILE"
    echo ""
    return 0
  else
    echo ""
    echo "============================================"
    echo "  WARNING: Certificate request failed"
    echo "============================================"
    echo ""
    echo "  The S/MIME key was generated (Key ID: $KEY_ID), but the certificate"
    echo "  request failed. This usually means the WireGuard tunnel to the CA"
    echo "  is not yet established."
    echo ""
    echo "  HTTP status: $http_code"
    echo "  Response from smimekeys-client:"
    echo "$CSR_RESPONSE" | jq . 2>/dev/null || echo "  $CSR_RESPONSE"
    echo ""
    echo "  To retry certificate issuance later, run:"
    echo "    ./scripts/onboard.sh --regenerate-cert"
    echo ""
    return 1
  fi
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

# Track failures
ONBOARD_WARNINGS=0

load_onboard_config
update_env_settings
generate_smime_key_and_csr || ONBOARD_WARNINGS=$((ONBOARD_WARNINGS + 1))

if [ "$INITIAL_SETUP" = false ]; then
  setup_wireguard_peer
  restart_services
fi

echo "============================================"
if [ $ONBOARD_WARNINGS -gt 0 ]; then
  echo "  Onboarding Complete (with warnings)"
else
  echo "  Onboarding Complete"
fi
echo "============================================"
echo ""
echo "  Mail domains:  $MAIL_DOMAINS"
echo "  Mail hostname: $MAIL_HOSTNAME"
if [ -n "$WG_PEER_ENDPOINT" ]; then
  echo "  WG peer:       $WG_PEER_NAME ($WG_PEER_ENDPOINT)"
fi
if [ $ONBOARD_WARNINGS -gt 0 ]; then
  echo ""
  echo "  ⚠ Certificate issuance failed (WireGuard tunnel may not be established yet)."
  echo "    Retry with: ./scripts/onboard.sh --regenerate-cert"
fi
echo ""
echo "  To add or change domains:"
echo "    1. Edit customer-config.sh (update MAIL_DOMAINS)"
echo "    2. Run: ./scripts/onboard.sh"
echo ""
echo "  To regenerate S/MIME certificate:"
echo "    ./scripts/onboard.sh --regenerate-cert"
echo ""

# Exit with warning code so callers can detect partial success
# Exit 0 = full success, Exit 2 = partial success (cert failed)
exit $( [ $ONBOARD_WARNINGS -gt 0 ] && echo 2 || echo 0 )
