#!/bin/sh
set -e

KEYCLOAK_URL="http://keycloak:8080"
ADMIN_USER="${KEYCLOAK_ADMIN_USER:-admin}"
ADMIN_PASSWORD="${KEYCLOAK_ADMIN_PASSWORD:-admin}"

echo "=== Keycloak Admin Init ==="

# Authenticate via password grant (succeeds even when required actions are pending)
TOKEN_RESPONSE=$(curl -s \
  -d "client_id=admin-cli" \
  -d "username=${ADMIN_USER}" \
  -d "password=${ADMIN_PASSWORD}" \
  -d "grant_type=password" \
  "${KEYCLOAK_URL}/realms/master/protocol/openid-connect/token")

ACCESS_TOKEN=$(echo "${TOKEN_RESPONSE}" | jq -r '.access_token // empty')

if [ -z "${ACCESS_TOKEN}" ]; then
  echo "Cannot authenticate with configured credentials — password may already have been changed"
  exit 0
fi

echo "Authenticated as ${ADMIN_USER}"

# Locate the user in the master realm
USER_ID=$(curl -sf \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  "${KEYCLOAK_URL}/admin/realms/master/users?username=${ADMIN_USER}&exact=true" \
  | jq -r '.[0].id // empty')

if [ -z "${USER_ID}" ]; then
  echo "ERROR: User '${ADMIN_USER}' not found in master realm"
  exit 1
fi

# Fetch full user record
USER_RECORD=$(curl -sf \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  "${KEYCLOAK_URL}/admin/realms/master/users/${USER_ID}")

# Skip if UPDATE_PASSWORD is already required
if echo "${USER_RECORD}" | jq -e '((.requiredActions // []) | index("UPDATE_PASSWORD")) != null' > /dev/null 2>&1; then
  echo "UPDATE_PASSWORD already required — nothing to do"
  exit 0
fi

# Append UPDATE_PASSWORD to any existing required actions and apply
NEW_ACTIONS=$(echo "${USER_RECORD}" | jq '(.requiredActions // []) + ["UPDATE_PASSWORD"]')

curl -sf \
  -X PUT \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  "${KEYCLOAK_URL}/admin/realms/master/users/${USER_ID}" \
  -d "{\"requiredActions\": ${NEW_ACTIONS}}"

echo "Done — admin must change password on next login"
