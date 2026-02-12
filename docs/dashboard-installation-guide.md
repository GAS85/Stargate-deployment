# Stargate Dashboard Installation UI - Technical Specification

This document describes how the Dashboard frontend should handle the Stargate installation configuration and process.

## Overview

The Dashboard UI will guide users through a step-by-step installation wizard that:
1. Collects configuration values via form inputs
2. Saves values to `/root/stargate/customer-config.sh` on the VM
3. Triggers the installation script
4. Monitors service health via `/liveness` endpoints
5. Proceeds to onboarding once installation completes

---

## Phase 1: Installation

### Step 1: Customer Identification

| Variable | Type | Required | Default | Validation | Description |
|----------|------|----------|---------|------------|-------------|
| `CUSTOMER_NAME` | string | ✅ Yes | - | Non-empty, alphanumeric + spaces | Customer/Organization name |
| `DEPLOYMENT_NAME` | string | ✅ Yes | - | Non-empty, lowercase alphanumeric + hyphens | Deployment identifier (e.g., "stargate-production") |

**UI Hints:**
- Show example values: "Acme Corporation", "stargate-acme-prod"
- `DEPLOYMENT_NAME` should auto-suggest based on `CUSTOMER_NAME` (lowercase, hyphenated)

---

### Step 2: Mail Configuration

| Variable | Type | Required | Default | Validation | Description |
|----------|------|----------|---------|------------|-------------|
| `MAIL_DOMAIN` | string | ✅ Yes | - | Valid domain format | Primary mail domain (e.g., "example.com") |
| `MAIL_HOSTNAME` | string | ❌ No | `mail.<MAIL_DOMAIN>` | Valid FQDN | SMTP hostname for HELO/EHLO |
| `MXENGINE_PUBLIC_ADDRESS` | string | ✅ Yes | - | Valid URL (http/https) | Public URL where sealer can reach mxengine |

**UI Hints:**
- Auto-populate `MAIL_HOSTNAME` as `mail.{MAIL_DOMAIN}` when user enters domain
- `MXENGINE_PUBLIC_ADDRESS` example: `http://203.0.113.10:8084` or `https://mxengine.example.com`
- Consider adding a "detect public IP" helper button

---

### Step 3: S/MIME Certificate Configuration

| Variable | Type | Required | Default | Validation | Description |
|----------|------|----------|---------|------------|-------------|
| `CERT_DNS_NAMES` | string | ✅ Yes | - | Comma-separated valid domains | DNS names for the certificate |
| `CERT_ORGANIZATION` | string | ✅ Yes | - | Non-empty | Organization name for cert subject |
| `CERT_COMMON_NAME` | string | ✅ Yes | - | Non-empty | Common Name for cert subject |
| `CERT_COUNTRIES` | string | ✅ Yes | - | Comma-separated 2-letter country codes | Countries for cert subject |

**UI Hints:**
- Auto-populate `CERT_DNS_NAMES` with `{MAIL_DOMAIN},mail.{MAIL_DOMAIN}` from Step 2
- Auto-populate `CERT_ORGANIZATION` and `CERT_COMMON_NAME` from `CUSTOMER_NAME`
- `CERT_COUNTRIES` should use a multi-select dropdown with country codes (ISO 3166-1 alpha-2)

---

### Step 4: WireGuard Configuration

| Variable | Type | Required | Default | Validation | Description |
|----------|------|----------|---------|------------|-------------|
| `WG_LOCAL_IP` | string | ✅ Yes | - | Valid IP in 10.0.0.0/8 range | Local WireGuard IP (MUST BE UNIQUE) |
| `WG_INTERFACE_PORT` | number | ❌ No | `51820` | Valid port 1024-65535 | WireGuard UDP port |
| `WG_PRIVATE_KEY` | string | ❌ No | Auto-generated | Valid WireGuard key or empty | WireGuard private key |

**UI Hints:**
- ⚠️ Show warning: "Each deployment MUST have a unique IP. Contact Vereign to avoid conflicts."
- `WG_PRIVATE_KEY` should be hidden/readonly - explain it's auto-generated on first install
- Suggest common IPs: 10.0.0.1, 10.0.0.2, etc.

---

### Step 5: WireGuard Peer Configuration

| Variable | Type | Required | Default | Validation | Description |
|----------|------|----------|---------|------------|-------------|
| `WG_PEER_NAME` | string | ✅ Yes | - | Non-empty | Human-readable connection name |
| `WG_PEER_PUBLIC_KEY` | string | ✅ Yes | - | Valid WireGuard public key (44 chars, base64) | Remote peer's public key |
| `WG_PEER_ENDPOINT` | string | ✅ Yes | - | Format: `host:port` | Remote peer endpoint |
| `WG_PEER_IP` | string | ✅ Yes | - | Valid IP address | Remote peer's WireGuard IP |
| `WG_PEER_PORT` | number | ❌ No | `9090` | Valid port | Communication port |
| `WG_PEER_CONNECTION_ID` | string | ❌ No | Auto-generated UUID v7 | Valid UUID or empty | Unique connection ID |
| `WG_PEER_ALLOWED_IPS` | string | ❌ No | `{WG_PEER_IP}/32` | Valid CIDR notation | Allowed IP ranges |
| `WG_PEER_EXTERNAL_ID` | string | ❌ No | - | Any string | External org/domain identifier |
| `WG_PEER_DESCRIPTION` | string | ❌ No | - | Any string | Connection description |

**UI Hints:**
- Pre-fill for Vereign dev connection:
  - `WG_PEER_NAME`: "dev"
  - `WG_PEER_PUBLIC_KEY`: "WhTN0ekf/jT+wAv9kIIHmwMLPWr9Gv1MXxnvAkJKbHU="
  - `WG_PEER_ENDPOINT`: "46.225.6.233:31820"
  - `WG_PEER_IP`: "10.0.0.2"
  - `WG_PEER_EXTERNAL_ID`: "vereign-cdn.com"

---

### Step 6: Optional Configuration (Collapsible/Advanced)

These can be shown in an "Advanced Settings" expandable section:

#### Database Configuration
| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `POSTGRES_USER` | string | ❌ No | `postgres` | PostgreSQL username |
| `POSTGRES_PASSWORD` | string | ❌ No | Auto-generated | PostgreSQL password |

#### Object Storage Configuration
| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `MINIO_ROOT_USER` | string | ❌ No | `minioadmin` | MinIO username |
| `MINIO_ROOT_PASSWORD` | string | ❌ No | Auto-generated | MinIO password |
| `S3_BUCKET_NAME` | string | ❌ No | `stargate-bucket` | S3 bucket name |

#### Application Versions
| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `SMIMEKEYS_VERSION` | string | ❌ No | `latest` | S/MIME Keys service version |
| `POLICY_VERSION` | string | ❌ No | `latest` | Policy service version |
| `IDAGENT_VERSION` | string | ❌ No | `latest` | ID Agent service version |
| `MXENGINE_VERSION` | string | ❌ No | `v0.0.32` | MX Engine service version |

#### Policy Sync Configuration
| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `POLICY_SYNC_REPO_URL` | string | ❌ No | - | Git repo URL for policies |
| `POLICY_SYNC_REPO_USER` | string | ❌ No | - | Git username |
| `POLICY_SYNC_REPO_PASS` | string | ❌ No | - | Git password/token |
| `POLICY_SYNC_REPO_BRANCH` | string | ❌ No | default branch | Git branch |
| `POLICY_SYNC_REPO_FOLDER` | string | ❌ No | - | Subfolder in repo |
| `POLICY_SYNC_INTERVAL` | string | ❌ No | `1h` | Sync interval (e.g., "5m", "1h") |

#### Advanced Mail Configuration
| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `POSTFIX_ENABLE_IPV6` | boolean | ❌ No | `false` | Enable IPv6 for Postfix |
| `RELAYHOST` | string | ❌ No | - | Manual relay host override |
| `POSTFIX_MYNETWORKS` | string | ❌ No | Auto from SPF | Manual allowed networks |
| `DNS_SERVER` | string | ❌ No | System resolver | Custom DNS server |
| `DNS_TIMEOUT` | number | ❌ No | `2` | DNS timeout in seconds |

#### Monitoring Configuration
| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `LOKI_URL` | string | ❌ No | `https://loki.k8s.vereign-cdn.com` | Loki logging URL |

---

## API Endpoints Required

The Dashboard backend needs to expose these endpoints:

### Configuration Management

```
POST /api/config/save
```
**Request Body:**
```json
{
  "CUSTOMER_NAME": "Acme Corporation",
  "DEPLOYMENT_NAME": "stargate-acme",
  "MAIL_DOMAIN": "acme.com",
  ...
}
```
**Action:** Write values to `/root/stargate/customer-config.sh`

**Response:**
```json
{
  "success": true,
  "message": "Configuration saved"
}
```

---

### Installation Trigger

```
POST /api/install/start
```
**Action:** Execute `/root/stargate/scripts/install.sh`

**Response:**
```json
{
  "success": true,
  "jobId": "abc-123"
}
```

---

### Installation Status

```
GET /api/install/status
```
**Response:**
```json
{
  "status": "running" | "completed" | "failed",
  "progress": 75,
  "currentStep": "Starting services...",
  "logs": ["Line 1...", "Line 2..."]
}
```

---

### Service Health Check

```
GET /api/health/services
```
**Action:** Check `/liveness` endpoints of all services

**Response:**
```json
{
  "services": {
    "smimekeys-client": { "healthy": true, "version": "v0.0.3" },
    "policy": { "healthy": true, "version": "v0.0.4" },
    "idagent": { "healthy": true, "version": "v0.0.5" },
    "mxengine": { "healthy": true, "version": "v0.0.32" },
    "vault": { "healthy": true },
    "postgres": { "healthy": true },
    "postfix": { "healthy": true }
  },
  "allHealthy": true
}
```

Service liveness endpoints:
- smimekeys-client: `http://localhost:8081/liveness`
- policy: `http://localhost:8082/liveness`
- idagent: `http://localhost:8083/liveness`
- mxengine: `http://localhost:8084/liveness`

---

## Installation Flow State Machine

```
┌─────────────┐
│   INITIAL   │ ← Page load / refresh
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  STEP_1     │ Customer Identification
└──────┬──────┘
       │ Next
       ▼
┌─────────────┐
│  STEP_2     │ Mail Configuration
└──────┬──────┘
       │ Next
       ▼
┌─────────────┐
│  STEP_3     │ S/MIME Certificate
└──────┬──────┘
       │ Next
       ▼
┌─────────────┐
│  STEP_4     │ WireGuard Local
└──────┬──────┘
       │ Next
       ▼
┌─────────────┐
│  STEP_5     │ WireGuard Peer
└──────┬──────┘
       │ Next
       ▼
┌─────────────┐
│  STEP_6     │ Advanced Settings (optional)
└──────┬──────┘
       │ Next
       ▼
┌─────────────┐
│  SUMMARY    │ Review all values
└──────┬──────┘
       │ Proceed
       ▼
┌─────────────┐
│ INSTALLING  │ Show spinner/progress
└──────┬──────┘
       │ Complete
       ▼
┌─────────────┐
│  COMPLETE   │ Show green checkmarks ✓
└──────┬──────┘
       │ Onboard
       ▼
┌─────────────┐
│ ONBOARDING  │ Phase 2 starts
└─────────────┘
```

---

## Error Handling

### Validation Errors
- Show inline validation errors on each field
- Disable "Next" button until all required fields are valid
- Highlight invalid fields with red border

### Installation Failures
If installation fails:
1. Show error message with details
2. Show relevant log output
3. Provide "Retry" button to attempt installation again
4. Provide "Back" button to modify configuration

### Interruption Handling
- If user refreshes during installation → restart from Step 1
- Consider storing progress in localStorage for recovery (optional enhancement)

---

## Auto-Generated Values

These values are generated during installation and should NOT be editable in the UI:

| Variable | When Generated | Notes |
|----------|----------------|-------|
| `VAULT_TOKEN` | During `vault-init` | Stored in `.env` and `customer-config.sh` |
| `WG_PRIVATE_KEY` | During `install.sh` if empty | Saved back to `customer-config.sh` |
| `WG_PEER_CONNECTION_ID` | During install if empty | UUID v7 auto-generated |
| `POSTGRES_PASSWORD` | During install if empty | Random secure password |
| `MINIO_ROOT_PASSWORD` | During install if empty | Random secure password |

---

## Summary Screen Content

Before triggering installation, show a summary:

```
┌────────────────────────────────────────────────────┐
│           Installation Summary                      │
├────────────────────────────────────────────────────┤
│ Customer: Acme Corporation                          │
│ Deployment: stargate-acme                           │
├────────────────────────────────────────────────────┤
│ Mail Domain: acme.com                               │
│ Mail Hostname: mail.acme.com                        │
│ MXEngine URL: https://mxengine.acme.com             │
├────────────────────────────────────────────────────┤
│ Certificate DNS: acme.com, mail.acme.com            │
│ Organization: Acme Corporation                      │
│ Countries: US, DE                                   │
├────────────────────────────────────────────────────┤
│ WireGuard IP: 10.0.0.5                              │
│ WireGuard Port: 51820                               │
├────────────────────────────────────────────────────┤
│ Peer: dev (46.225.6.233:31820)                      │
│ Peer IP: 10.0.0.2                                   │
├────────────────────────────────────────────────────┤
│                                                     │
│            [ Back ]    [ Proceed with Install ]     │
│                                                     │
└────────────────────────────────────────────────────┘
```

---

## Post-Installation Screen

After successful installation:

```
┌────────────────────────────────────────────────────┐
│         ✓ Installation Complete                     │
├────────────────────────────────────────────────────┤
│                                                     │
│  ✓ smimekeys-client    v0.0.3     Running          │
│  ✓ policy              v0.0.4     Running          │
│  ✓ idagent             v0.0.5     Running          │
│  ✓ mxengine            v0.0.32    Running          │
│  ✓ vault               v1.19.0    Running          │
│  ✓ postgres            v18        Running          │
│  ✓ postfix-relay                  Running          │
│                                                     │
├────────────────────────────────────────────────────┤
│                                                     │
│  CSR Generated: /root/stargate/secrets/signing-key.csr │
│  ⚠️ Submit this CSR to your CA to get the signed   │
│     certificate for S/MIME signing.                 │
│                                                     │
│              [ Download CSR ]  [ Start Onboarding ] │
│                                                     │
└────────────────────────────────────────────────────┘
```

---

## File Paths Reference

| File | Purpose |
|------|---------|
| `/root/stargate/customer-config.sh` | Main configuration file (edited by UI) |
| `/root/stargate/.env` | Generated environment file (do not edit directly) |
| `/root/stargate/scripts/install.sh` | Installation script |
| `/root/stargate/secrets/vault-keys.json` | Vault unseal keys (backup!) |
| `/root/stargate/secrets/signing-key.csr` | S/MIME CSR for CA signing |

---

## Phase 2: Onboarding

(To be defined based on onboarding requirements - likely includes:)
- Certificate upload after CA signing
- Initial policy configuration
- Test email sending
- Connection verification with remote peer
