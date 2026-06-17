#!/bin/sh
# =============================================================================
# Stalwart Provision Script (Docker Compose)
# =============================================================================
# Idempotently provisions Stalwart for the Stargate deployment:
#   1. Creates network listeners (SMTP, reinject, management HTTP)
#   2. Enables a Stdout tracer so logs land on docker stdout
#   3. Ensures the service domain exists
#   4. Sets SystemSettings (defaultHostname + defaultDomainId)
#   5. Creates the mtaconf service account
#
# Designed as a one-shot Docker Compose service (restart: "no").
# Safe to re-run: checks for existing objects before creating.
#
# Required env:
#   STALWART_RECOVERY_ADMIN   "admin:<password>" (recovery admin credentials)
#   MTACONF_SVC_PASSWORD      password for the mtaconf service account
# Optional env:
#   STALWART_URL              default http://stalwart:8080
#   STALWART_CLI_PATH         default /opt/stalwart-cli
#   STALWART_READY_RETRIES    readiness attempts, 3s apart (default 60)
#
# Internal: the mtaconf-svc admin account lives under a synthetic service
# domain (mtaconf.local). It exists only so mtaconf can authenticate to
# the Stalwart management API; it must NOT be a real mail-receiving
# domain, because Stalwart treats every registered Domain as
# accept-locally and would bounce production mail to that domain.
# Operators should never override this — that's why it's hardcoded here
# instead of being exposed in customer-config.
#
# The provisional SystemSettings.defaultHostname is also synthetic
# (mail.mtaconf.local). The real public mail hostname is set later via
# mtaconf when the operator submits the dashboard form (intent.hostname
# → SystemSettings.defaultHostname update).
# =============================================================================
set -eu
export HOME=/tmp

CLI="${STALWART_CLI_PATH:-/opt/stalwart-cli}"
URL="${STALWART_URL:-http://stalwart:8080}"
: "${STALWART_RECOVERY_ADMIN:?STALWART_RECOVERY_ADMIN (admin:password) is required}"
: "${MTACONF_SVC_PASSWORD:?MTACONF_SVC_PASSWORD is required}"
SVC="mtaconf-svc"
DOMAIN="mtaconf.local"
HOSTNAME="mail.${DOMAIN}"
RETRIES="${STALWART_READY_RETRIES:-60}"

AUSER="${STALWART_RECOVERY_ADMIN%%:*}"
APW="${STALWART_RECOVERY_ADMIN#*:}"
EMAIL="${SVC}@${DOMAIN}"

cli() { "$CLI" --url "$URL" --user "$AUSER" --password "$APW" "$@"; }
log() { echo "[provision] $*"; }

# =============================================================================
# 1. Wait for Stalwart management API
# =============================================================================
log "waiting for Stalwart at $URL"
i=0
until cli get SystemSettings >/dev/null 2>&1; do
  i=$((i + 1))
  if [ "$i" -ge "$RETRIES" ]; then
    log "ERROR: Stalwart not reachable after ${RETRIES} attempts"
    exit 1
  fi
  sleep 3
done
log "Stalwart reachable"

# =============================================================================
# 2. Create network listeners (idempotent)
# =============================================================================
create_listener() {
  local name="$1" bind="$2" protocol="$3" tls="${4:-false}"

  if cli query NetworkListener 2>/dev/null | grep -Fq "$name"; then
    log "listener '$name' already exists"
    return 0
  fi

  log "creating listener: $name (${protocol} on ${bind}, tls=${tls})"
  cli create NetworkListener \
    --field "name=${name}" \
    --field "bind={\"${bind}\": true}" \
    --field "protocol=${protocol}" \
    --field "useTls=${tls}"
}

# Content-filtering scope for the two SMTP listeners ('smtp' :25, 'reinject'
# :10026). Stalwart's milter `enable` field takes an Expression: yield "true"
# on a match, else "false". NOTE: 'match' is a Stalwart List, patched as an
# integer-keyed object ({"0": ...}) and NOT a JSON array -- an array is rejected
# with `invalidPatch: Invalid value for object property`.
SMTP_LISTENER_COND="listener == 'smtp' || listener == 'reinject'"
SMTP_LISTENERS="{\"match\":{\"0\":{\"if\":\"${SMTP_LISTENER_COND}\",\"then\":\"true\"}},\"else\":\"false\"}"

create_milter() {
  local name="$1" host="$2" port="$3"

  # MtaMilter has no 'name' property; its id is server-assigned. Identify an existing milter by its hostname (the only stable, operator-set key).
  if cli query MtaMilter 2>/dev/null | grep -Fq "$host"; then
    log "milter '$name' (${host}) already exists"
    return 0
  fi

  log "creating milter: $name (${host}:${port}, DATA stage, both SMTP listeners)"
  # stages is a Map<MtaStage> ({"<stage>": true}), not a list. The object id is assigned by Stalwart on create -- there is no settable name/id field.
  cli create MtaMilter \
    --field "hostname=${host}" \
    --field "port=${port}" \
    --field 'stages={"data":true}' \
    --field "enable=${SMTP_LISTENERS}" \
    --field "useTls=false" \
    --field "tempFailOnError=true"
}

# SMTP inbound (port 25) - receives external mail
create_listener "smtp" "0.0.0.0:25" "smtp" "false"

# Reinject (port 10026) - mxengine sends processed mail back here
create_listener "reinject" "0.0.0.0:10026" "smtp" "false"

# Management HTTP (port 8080) - already provided by recovery mode, but ensure
# it persists if recovery mode is ever disabled
create_listener "mgmt" "0.0.0.0:8080" "http" "false"

# =============================================================================
# 2b. Stdout tracer - emit Stalwart's own logs to docker stdout
# =============================================================================
# v0.16 stores tracer config in the settings backend; when the backend is
# empty (fresh Postgres) no tracer is enabled and `docker logs stalwart` is
# silent even though the server is healthy. Stalwart calls the Stdout/Console
# tracer's variant `Stdout` (Console is the display label).
if ! cli query Tracer 2>/dev/null | grep -Fq "Stdout"; then
  log "creating stdout tracer"
  cli create Tracer \
    --field "@type=Stdout" \
    --field "enable=true" \
    --field "level=info" \
    --field "ansi=false" \
    --field "multiline=false" \
    --field "buffered=false" \
    --field "lossy=false"
fi

# =============================================================================
# 2c. Content filtering: anti-virus (ClamAV milter)
# =============================================================================
# Anti-virus: ClamAV rejects infected mail at SMTP (OnInfected Reject in clamav-milter.conf); tempFailOnError defers mail if ClamAV is down instead of passing it unscanned (fail-closed).
create_milter "clamav" "${CLAMAV_MILTER_HOST:-clamav}" "${CLAMAV_MILTER_PORT:-7357}"

# Anti-spam: disabled. Stalwart's built-in spam filter is explicitly turned off
# here (rather than left unconfigured) so that re-running provision reconciles a
# previously-enabled install back to disabled: no X-Spam-* tagging and no spam
# scan at the DATA stage.
log "disabling built-in spam filter"
cli update SpamSettings singleton --field "enable=false"
#cli update MtaStageData singleton --field "enableSpamFilter=false"

# =============================================================================
# 2d. Rate limiting: global inbound + outbound throttles (5000/hour each)
# =============================================================================
# Each throttle is global (no `key` => applies server-wide; `match` defaults to
# {"else":"true"} so it fires on every message). When the limit is exceeded
# Stalwart rejects further inbound mail with `451 4.4.5 Rate limit exceeded` and
# defers outbound delivery until the rate drops below 5000/1h.
#
# CRITICAL -- `rate` is a nested Rate object {count, period}. Two things bite:
#   1. `period` is an INTEGER OF MILLISECONDS, not a Duration string. Sending
#      "1h"/"3600s" is rejected with `invalidPatch: Invalid path for Duration
#      (rate/period)` (the Duration leaf wants a number, not a string). 1h =
#      3600 * 1000 = 3600000. Verified against a built-in throttle, whose wire
#      form is {"count":25,"period":3600000}.
#   2. `rate` must be an OBJECT -- the string form "5000/1h" is rejected with
#      `Invalid value type for object`.
# The object is sent with `--json` (complete object); a populated nested object
# via `--field rate={...}` is unreliable, so we always use `--json`.
#
# Both MtaInboundThrottle and MtaOutboundThrottle REQUIRE a writable
# `description` on create (the schema docs label inbound's as read-only, but this
# build validates `description: required` and accepts the value), so we key
# idempotency on it for both. We match the description CLIENT-SIDE against the
# full row set rather than trusting `--where`, so we never accidentally reconcile
# one of Stalwart's built-in scoped throttles (e.g. "Sender IP throttle").
#
# A throttle failure is non-fatal: mtaconf gates on this one-shot completing
# (docker-compose: service_completed_successfully), so an aborted `cli create`
# under `set -eu` would block the whole mail stack from starting. We'd rather
# ship loudly-logged-unthrottled than not ship at all -- the WARNING surfaces in
# `docker logs stargate-stalwart-provision`.
RATE='{"count":5000,"period":3600000}'  # 5000 per hour; period in milliseconds

ensure_throttle() {
  local type="$1" desc="$2"
  local id
  # `--fields id,description --json` emits one JSON object per row; match our
  # exact description and pull its id (skips the built-in scoped throttles).
  id=$(cli query "$type" --fields id,description --json 2>/dev/null \
        | grep -F "\"description\":\"${desc}\"" \
        | sed -n 's/.*"id":"\([^"]*\)".*/\1/p' | head -n1) || true
  if [ -n "$id" ]; then
    log "${type} '${desc}' exists (id=${id}); reconciling rate to 5000/1h"
    cli update "$type" "$id" --json "{\"rate\":${RATE},\"enable\":true}" \
      || log "WARNING: failed to update ${type} ${id}; rate limit may be stale"
  else
    log "creating ${type} '${desc}': 5000/1h (global)"
    cli create "$type" \
      --json "{\"description\":\"${desc}\",\"rate\":${RATE},\"enable\":true}" \
      || log "WARNING: failed to create ${type} '${desc}'; mail is NOT rate-limited"
  fi
}

ensure_throttle MtaInboundThrottle "Global inbound rate limit"
ensure_throttle MtaOutboundThrottle "Global outbound rate limit"

# =============================================================================
# 2e. Data retention: hourly cleanup
# =============================================================================
# Hourly cleanup of the data store and the (reference-counted) blob store.
# Offset so the two purges don't compete for I/O. blob @ :05, data @ :15.
log "setting DataRetention cleanup schedules (blob hourly @ :05, data hourly @ :15)"
cli update DataRetention singleton \
  --field 'blobCleanupSchedule={"@type":"Hourly","minute":5}' \
  --field 'dataCleanupSchedule={"@type":"Hourly","minute":15}'

# =============================================================================
# 3. Ensure the domain exists
# =============================================================================
DID=$(cli query domain 2>/dev/null | awk -v d="$DOMAIN" 'NR>1 && index($0, d) {print $1; exit}') || true
if [ -z "$DID" ]; then
  log "creating domain: ${DOMAIN}"
  cli create domain \
    --field "name=${DOMAIN}" \
    --field 'aliases={}' \
    --field 'certificateManagement={"@type":"Manual"}' \
    --field 'dkimManagement={"@type":"Manual"}' \
    --field 'dnsManagement={"@type":"Manual"}' \
    --field 'subAddressing={"@type":"Enabled"}' \
    --field "isEnabled=true"
  DID=$(cli query domain 2>/dev/null | awk -v d="$DOMAIN" 'NR>1 && index($0, d) {print $1; exit}') || true
fi
[ -n "$DID" ] || { log "ERROR: could not resolve domain id for ${DOMAIN}"; exit 1; }
log "domain ${DOMAIN} id=${DID}"

# =============================================================================
# 4. Set SystemSettings (hostname + default domain)
# =============================================================================
# v0.16's SystemSettings requires both `defaultHostname` and `defaultDomainId`
# on every update — the validator runs against the full post-patch state, so
# subsequent partial updates (e.g. from mtaconf updating only the hostname)
# fail with "defaultDomainId: required" unless we seed both fields here.
log "setting SystemSettings: defaultHostname=${HOSTNAME}, defaultDomainId=${DID}"
cli update SystemSettings singleton \
  --field "defaultHostname=${HOSTNAME}" \
  --field "defaultDomainId=${DID}"

# =============================================================================
# 5. Ensure mtaconf service account exists
# =============================================================================
CRED='{"0":{"@type":"Password","secret":"'"${MTACONF_SVC_PASSWORD}"'"}}'
ROLES='{"@type":"Admin"}'

if cli query account 2>/dev/null | grep -Fq "$EMAIL"; then
  AID=$(cli query account 2>/dev/null | awk -v e="$EMAIL" 'NR>1 && index($0, e) {print $1; exit}') || true
  log "account ${EMAIL} exists (id=${AID}); reconciling password + role"
  cli update account "$AID" \
    --field "credentials=${CRED}" \
    --field "roles=${ROLES}"
else
  log "creating account: ${EMAIL} (role Admin)"
  cli create account/user \
    --field "name=${SVC}" \
    --field "domainId=${DID}" \
    --field "credentials=${CRED}" \
    --field "roles=${ROLES}" \
    --field 'permissions={"@type":"Inherit"}'
fi

# =============================================================================
# 6. Reload settings so listeners take effect without restart
# =============================================================================
log "triggering ReloadSettings"
cli create action/ReloadSettings 2>/dev/null || log "ReloadSettings trigger skipped"

log "done: Stalwart provisioned, mtaconf service account ready (login: ${EMAIL})"
