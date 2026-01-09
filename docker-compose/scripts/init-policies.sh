#!/bin/sh
set -e

echo "=== Policy Initialization Script ==="

POSTGRES_HOST="${POSTGRES_HOST:-postgres}"
POSTGRES_PORT="${POSTGRES_PORT:-5432}"
POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-postgres}"
POSTGRES_DB="${POSTGRES_DB:-policy}"

export PGPASSWORD="$POSTGRES_PASSWORD"

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
until psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c '\q' 2>/dev/null; do
  sleep 2
done

echo "PostgreSQL is ready. Inserting policies..."

# Function to upsert a policy
upsert_policy() {
  local filename="$1"
  local name="$2"
  local policy_group="$3"
  local rego_file="$4"
  local data="${5:-{}}"
  
  # Read the rego content
  local rego_content
  rego_content=$(cat "$rego_file")
  
  echo "Upserting policy: $name (group: $policy_group)"
  
  psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" <<EOF
INSERT INTO policies (filename, name, policy_group, rego, data)
VALUES ('$filename', '$name', '$policy_group', \$\$${rego_content}\$\$, '$data')
ON CONFLICT (name, policy_group)
DO UPDATE SET 
  filename = EXCLUDED.filename,
  rego = EXCLUDED.rego,
  data = EXCLUDED.data,
  updated_at = EXTRACT(epoch FROM now())::bigint;
EOF
}

# Insert the delivery_strategy policy
if [ -f "/policies/alpha/deliveryStrategy/policy.rego" ]; then
  upsert_policy \
    "policy.rego" \
    "deliveryStrategy" \
    "alpha" \
    "/policies/alpha/deliveryStrategy/policy.rego" \
    "{}"
else
  echo "WARNING: /policies/alpha/deliveryStrategy/policy.rego not found"
fi

echo ""
echo "=== Current Policies ==="
psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -c "SELECT id, name, policy_group, filename, created_at, updated_at FROM policies;"

echo ""
echo "Policy initialization complete!"
