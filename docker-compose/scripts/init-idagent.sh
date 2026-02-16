#!/bin/sh
set -e

echo "=== IDAgent Connection Initialization ==="

# Check if required environment variables are set
if [ -z "$WG_PEER_PUBLIC_KEY" ]; then
  echo "WG_PEER_PUBLIC_KEY not set, skipping connection initialization"
  exit 0
fi

if [ -z "$WG_PEER_ENDPOINT" ]; then
  echo "WG_PEER_ENDPOINT not set, skipping connection initialization"
  exit 0
fi

# Set defaults
WG_PEER_CONNECTION_ID="${WG_PEER_CONNECTION_ID:-}"
WG_PEER_NAME="${WG_PEER_NAME:-default}"
WG_PEER_IP="${WG_PEER_IP:-10.0.0.2}"
WG_PEER_PORT="${WG_PEER_PORT:-9090}"
WG_PEER_ALLOWED_IPS="${WG_PEER_ALLOWED_IPS:-${WG_PEER_IP}/32}"
WG_PEER_EXTERNAL_ID="${WG_PEER_EXTERNAL_ID:-}"
WG_PEER_DESCRIPTION="${WG_PEER_DESCRIPTION:-WireGuard peer connection}"
WG_TRANSPORT_MODE="${WG_TRANSPORT_MODE:-tcp}"

# If connection_id not provided, generate UUID v4 using PostgreSQL
if [ -z "$WG_PEER_CONNECTION_ID" ]; then
  echo "Generating connection_id using PostgreSQL gen_random_uuid()..."
  WG_PEER_CONNECTION_ID=$(psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d idagent -tAc "SELECT gen_random_uuid();")
fi

echo "Configuration:"
echo "  connection_id: $WG_PEER_CONNECTION_ID"
echo "  name: $WG_PEER_NAME"
echo "  public_key: $WG_PEER_PUBLIC_KEY"
echo "  endpoint: $WG_PEER_ENDPOINT"
echo "  wireguard_ip: $WG_PEER_IP"
echo "  wireguard_port: $WG_PEER_PORT"
echo "  allowed_ips: $WG_PEER_ALLOWED_IPS"
echo "  external_id: $WG_PEER_EXTERNAL_ID"
echo "  description: $WG_PEER_DESCRIPTION"
echo "  transport: $WG_TRANSPORT_MODE"
echo ""

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
until pg_isready -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d idagent; do
  sleep 2
done

# Check if connections table exists (wait for idagent to create schema)
echo "Waiting for connections table to exist..."
for i in $(seq 1 60); do
  TABLE_EXISTS=$(psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d idagent -tAc "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'connections');")
  if [ "$TABLE_EXISTS" = "t" ]; then
    echo "Connections table found!"
    break
  fi
  echo "  Attempt $i/60 - waiting for idagent to create schema..."
  sleep 2
done

if [ "$TABLE_EXISTS" != "t" ]; then
  echo "ERROR: connections table not found after 120 seconds"
  exit 1
fi

# Check if connection already exists (by public_key or connection_id)
EXISTING=$(psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d idagent -tAc \
  "SELECT connection_id FROM connections WHERE public_key = '$WG_PEER_PUBLIC_KEY' OR connection_id = '$WG_PEER_CONNECTION_ID' LIMIT 1;")

if [ -n "$EXISTING" ]; then
  echo "Connection already exists with id: $EXISTING"
  echo "Updating existing connection..."
  
  psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d idagent <<EOF
UPDATE connections SET
  name = '$WG_PEER_NAME',
  public_key = '$WG_PEER_PUBLIC_KEY',
  endpoint = '$WG_PEER_ENDPOINT',
  wireguard_ip = '$WG_PEER_IP',
  wireguard_port = $WG_PEER_PORT,
  allowed_ips = '$WG_PEER_ALLOWED_IPS',
  description = '$WG_PEER_DESCRIPTION',
  transport = '$WG_TRANSPORT_MODE',
  status = 'completed',
  updated_at = EXTRACT(EPOCH FROM NOW())::BIGINT
WHERE connection_id = '$EXISTING' OR public_key = '$WG_PEER_PUBLIC_KEY';
EOF
  
  echo "Connection updated successfully!"
else
  echo "Creating new connection..."
  
  psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d idagent <<EOF
INSERT INTO connections (
  connection_id,
  name,
  public_key,
  preshared_key,
  endpoint,
  wireguard_ip,
  wireguard_port,
  allowed_ips,
  description,
  transport,
  status,
  created_at,
  updated_at
) VALUES (
  '$WG_PEER_CONNECTION_ID',
  '$WG_PEER_NAME',
  '$WG_PEER_PUBLIC_KEY',
  NULL,
  '$WG_PEER_ENDPOINT',
  '$WG_PEER_IP',
  $WG_PEER_PORT,
  '$WG_PEER_ALLOWED_IPS',
  '$WG_PEER_DESCRIPTION',
  '$WG_TRANSPORT_MODE',
  'completed',
  EXTRACT(EPOCH FROM NOW())::BIGINT,
  EXTRACT(EPOCH FROM NOW())::BIGINT
);
EOF
  
  echo "Connection created successfully!"
fi

echo ""
echo "=== IDAgent Connection Initialization Complete ==="

# === connection_external_ids table ===
if [ -n "$WG_PEER_EXTERNAL_ID" ]; then
  echo ""
  echo "=== Setting up connection_external_ids ==="

  # Wait for connection_external_ids table to exist
  echo "Waiting for connection_external_ids table to exist..."
  for i in $(seq 1 60); do
    TABLE_EXISTS=$(psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d idagent -tAc "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'connection_external_ids');")
    if [ "$TABLE_EXISTS" = "t" ]; then
      echo "connection_external_ids table found!"
      break
    fi
    echo "  Attempt $i/60 - waiting for table..."
    sleep 2
  done

  if [ "$TABLE_EXISTS" = "t" ]; then
    # Use the actual connection_id (could be the existing one or newly generated)
    CONN_ID="${EXISTING:-$WG_PEER_CONNECTION_ID}"

    EXISTING_EXT=$(psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d idagent -tAc \
      "SELECT connection_id FROM connection_external_ids WHERE connection_id = '$CONN_ID' LIMIT 1;")

    if [ -n "$EXISTING_EXT" ]; then
      echo "Connection external id already exists: $EXISTING_EXT"
      echo "Updating existing connection_external_ids..."

      psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d idagent <<EOF
UPDATE connection_external_ids SET
  external_id = '$WG_PEER_EXTERNAL_ID',
  connection_id = '$CONN_ID',
  updated_at = EXTRACT(EPOCH FROM NOW())::BIGINT
WHERE connection_id = '$CONN_ID';
EOF
    else
      echo "Creating new connection_external_ids entry..."

      psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d idagent <<EOF
INSERT INTO connection_external_ids (
  external_id,
  connection_id
) VALUES (
  '$WG_PEER_EXTERNAL_ID',
  '$CONN_ID'
);
EOF
    fi
    echo "connection_external_ids setup complete!"
  else
    echo "WARNING: connection_external_ids table not found, skipping external_id setup"
  fi
fi

# Show current connections
echo ""
echo "Current connections:"
psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d idagent -c \
  "SELECT connection_id, name, wireguard_ip, wireguard_port, transport, status FROM connections;"
