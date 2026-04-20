# Stargate Deployment Instruction

### Alpha and Beta phase recommendations 

#### Alpha phase 

The alpha phase of HIN MGW is an early testing stage where most of the functionalities are built but still incomplete and may require improvements in processes and functionality.

Recommendations and Expectations for the Alpha Phase
* As HIN MGW is still under rapid development, you should expect periodic requests to update your instance.
* We recommend preparing and using a test domain, not a production domain, during the alpha phase.
* If you have a test environment available, please perform the initial installation there and connect it to a test email system.
* Please do not use real production traffic before the official production release date. Routing production traffic during the alpha phase is done at your own risk.
  * During the Alpha and Beta testing phases, you are allowed to register any test domain you own. During the onboarding process, a CSR request will be sent to the HIN Test CA server, and the certificate will be issued automatically. 

#### Beta phase 

The beta phase will be announced separately. During beta, the system will still be connected to the HIN Test CA. Real traffic testing can begin once announced.

### Applications
- **smimekeys-client** - S/MIME keys client service (port 8081)
- **policy** - Policy service (port 8082)
- **idagent** - ID Agent service (port 8083, WireGuard: 19818/tcp+udp)
- **mxengine** - MX Engine service (port 8084, SMTP: 1587)
- **policy-sync** - Syncs OPA/Rego policies from Git repository to database (runs continuously)

### Infrastructure
- **PostgreSQL** - Database (port 5432)
- **Vault** - Secrets management (port 8200)
- **MinIO** - S3-compatible storage (API: 9000, Console: 9001)
- **Postfix Relay** - Mail relay server (port 25) - auto-configures from DNS

### Init Containers
- **vault-init** - Initializes and unseals Vault on first run
- **idagent-init** - Creates WireGuard peer connection in idagent database

### Monitoring
- **node-exporter** - Host metrics for Prometheus (port 9100)
- **version-collector** - Collects app versions from `/liveness` endpoints for node-exporter
- **Promtail** - Log collector for Loki (ships app logs)

## Quick Start

### Installation options 

* Docker installation [Prerequisites](#prerequisites)
* VM image installation
  * Azure VM image installation [Azure-VM-image-install.md](Azure-VM-image-install.md)
  * Windows 11 pro (Hyper-V) image installation [Windows11pro-image-install.md](Windows11pro-image-install.md)
  * VMware image installation [VMware-image-install.md](VMware-image-install.md)
  * Proxmox image installation [Proxmox-image-install.md](Proxmox-image-install.md)
* HELM charts [helm-deploy.md](helm-deploy.md)

### Exchange Integration

* [Exchange-integration.md](Exchange-integration.md) - Configure Microsoft Exchange (Online and On-Premises) connectors and transport rules to route mail through Stargate

### Prerequisites

**Server Requirements:**
- 4 CPU cores (recommended minimum)
- 8 GB RAM (recommended minimum)
- 30 GB storage (recommended minimum)
- Docker will be installed automatically if missing
- Ensure there is an internet connection on the machine where you are installing Stargate services
- Ensure traffic is properly configured to reach Stargate instance

**Supported Linux Distributions:**
- RHEL 8, 9 and 10 compatible distributions such as Alma Linux, Rocky Linux, Centos Stream
- Ubuntu 22 and 24
- Debian 11, 12 and 13

**Inbound Network Access (firewall must allow):**
| Port | Protocol | Purpose |
|------|----------|---------|
| 25 | TCP | SMTP - receiving mail from external servers |
| 8084 | TCP | HTTP - seal callback from remote sealer service |
| 19818 | TCP+UDP | WireGuard - encrypted tunnel for agent-to-agent communication |

**Outbound Network Access (server must reach):**
| Destination | Port | Purpose |
|-------------|------|---------|
| registry.vereign.io | 443 | Docker image registry |
| mxengine-dev.k8s.vereign-cdn.com | 443 | Remote sealer service |
| smimekeys-ca-dev.k8s.vereign-cdn.com | 443 | S/MIME CA service |
| loki.infra.vereign-cdn.com | 443 | Log shipping (Promtail → Loki) |
| vereign-issuer.vrgnservices.eu | 443 | Issuer service |
| vereign-verifier.vrgnservices.eu | 4433 | Verifier service |
| Destination mail servers | 25 | Outbound mail delivery (via MX lookup) |

**DNS Access:**
- Server must be able to resolve DNS (MX, SPF, A records)
- Used for mail routing and SPF-based network allowlisting

### Step 1: Configure Customer Settings

Before installation, create and fill in the customer configuration file:

```bash
# Copy the template
cp customer-config.example customer-config.sh

# Edit the config file
nano customer-config.sh
```

**Required settings — you must fill these in:**

| Setting | Description | Example |
|---------|-------------|---------|
| `SERVER_STATIC_IP` | This server's real static public IP. Used to derive WireGuard tunnel address and MXEngine callback URL. | `203.0.113.10` |
| `CUSTOMER_NAME` | Customer/organization name (used for identification, logging, and as default certificate organization). | `Acme Corp` |
| `DEPLOYMENT_NAME` | Unique deployment identifier (used in log labels and Promtail hostname). | `stargate-acme` |
| `MAIL_DOMAINS` | Mail relay domains, comma-separated for multiple. MX and SPF records are looked up from DNS. | `example.com` or `example.com,example.org` |

**Auto-derived settings — leave empty unless you need to override:**

| Setting | Derived from | Default |
|---------|-------------|---------|
| `MXENGINE_PUBLIC_ADDRESS` | `SERVER_STATIC_IP` | `http://<SERVER_STATIC_IP>:8084` |
| `CERT_DNS_NAMES` | `MAIL_DOMAINS` + `MAIL_HOSTNAME` | `example.com,mail.example.com` |
| `CERT_ORGANIZATION` | `CUSTOMER_NAME` | `Acme Corp` |
| `CERT_COMMON_NAME` | `CUSTOMER_NAME` | `Acme Corp Mail Signing` |
| `MAIL_HOSTNAME` | First domain in `MAIL_DOMAINS` | `mail.example.com` |

**S/MIME certificate settings:**

| Setting | Description | Default |
|---------|-------------|---------|
| `CERT_COUNTRIES` | Country codes for certificate subject (2-letter ISO) | `US` |
| `CERT_CA_IDAGENT_DOMAIN` | CA domain for certificate issuance via WireGuard tunnel | `hintest.ch` |

**WireGuard peer settings (pre-filled for HIN Test):**

The template comes with HIN Test peer defaults. These work out of the box for the alpha/beta phase. Override only if connecting to a different peer.

| Setting | Default (HIN Test) | Description |
|---------|---------------------|-------------|
| `WG_PEER_NAME` | `hin-test` | Human-readable peer name |
| `WG_PEER_PUBLIC_KEY` | `ol2zlG40M7+Rn81V9RUFmkIQV2ILLmEJHZww7HfoLxA=` | Remote peer's WireGuard public key |
| `WG_PEER_ENDPOINT` | `5.102.144.182:19818` | Remote peer's public endpoint (host:port) |
| `WG_PEER_IP` | `5.102.144.182` | Remote peer's WireGuard tunnel IP |
| `WG_PEER_PORT` | `9090` | HTTP communication port on the remote peer |
| `WG_PEER_EXTERNAL_ID` | `hintest.ch` | External identifier for routing (typically the peer's domain) |

> **Note:** `WG_PEER_IP` is the peer's *tunnel address* (used for routing inside WireGuard), while `WG_PEER_PORT` is the HTTP port the peer's IDAgent listens on for API calls over the tunnel.

**WireGuard local settings (typically left at defaults):**

| Setting | Default | Description |
|---------|---------|-------------|
| `WG_PRIVATE_KEY` | *(auto-generated)* | Generated by IDAgent on first run, then saved to `customer-config.sh` |
| `WG_LOCAL_IP` | `SERVER_STATIC_IP` | Auto-derived. Only override if you need a different tunnel address. |
| `WG_INTERFACE_PORT` | `19818` | WireGuard tunnel port (both TCP and UDP are exposed) |
| `WG_TRANSPORT_MODE` | `tcp` | Transport protocol: `tcp` (default, works through most firewalls) or `udp` |

**Optional settings (have sensible defaults):**

| Setting | Default | Description |
|---------|---------|-------------|
| `POSTGRES_PASSWORD` | *(auto-generated)* | Auto-generated 24-char random password if empty |
| `MINIO_ROOT_PASSWORD` | *(auto-generated)* | Auto-generated 24-char random password if empty |
| `OUTBOUND_SEALER_MX_DOMAIN` | `hintest.ch` | Sealer MX domain for outbound seal delivery |
| `POLICY_SYNC_REPO_URL` | GitHub HIN Stargate policies | Git repo URL for OPA/Rego policy sync |
| `LOKI_URL` | `https://loki.infra.vereign-cdn.com` | Loki endpoint for centralized log shipping |

**Auto-generated (do not set manually):**
- `VAULT_TOKEN` — Generated by Vault during first initialization, saved to `customer-config.sh`
- `WG_PRIVATE_KEY` — Generated by IDAgent on first run, saved to `customer-config.sh`

### Step 2: Deploy to a Server

```bash
# Copy files to the server
scp -r docker-compose/* your-server:/path/to/stargate/

# SSH to server
ssh your-server
cd /path/to/stargate

# Create customer config from template
cp customer-config.example customer-config.sh
nano customer-config.sh   # Fill in required settings (see Step 1)

# Run installation
chmod +x scripts/*.sh
./scripts/install.sh
```

### Step 3: What Install Does

The install script (`install.sh`) performs the following steps:

1. **Check dependencies** — Detects Docker, Docker Compose, and `jq`. If missing, installs them automatically (supports Ubuntu/Debian, RHEL/AlmaLinux/Rocky).
2. **Load and validate** `customer-config.sh` — Checks required fields (`SERVER_STATIC_IP`, `CUSTOMER_NAME`, `DEPLOYMENT_NAME`, `MAIL_DOMAINS`). Auto-derives optional fields (certificate names, MXEngine URL, etc.).
3. **Generate `.env`** from customer config — Auto-generates passwords if not set.
4. **Start all services** via Docker Compose (infrastructure + applications).
5. **Initialize Vault** — The `vault-init` container initializes, unseals, and creates KV-v2 secret mounts. Optionally writes the WireGuard private key to Vault.
6. **Save Vault keys** to `secrets/vault-keys.json` and update `.env` with the root token. The token is also saved to `customer-config.sh` for persistence across VM recreations.
7. **Restart application services** to pick up the Vault token.
8. **Run initial onboarding** (`onboard.sh --initial-setup`):
   - Generate S/MIME signing key and CSR (saved to `secrets/signing-key.csr`)
   - Set up WireGuard peer connection in the database
   - If the WireGuard tunnel to the CA is not yet established, CSR submission may fail — this is expected on first install. Services still run; retry with `./scripts/onboard.sh --regenerate-cert` once the tunnel is up.
9. **Save WireGuard private key** to `customer-config.sh` — extracted from Vault after IDAgent generates it.
10. **Set up daily backup** cron job (runs at 2:00 AM).

### Step 4: Onboard Domains (Post-Install)

After initial installation, use `onboard.sh` to manage domains, certificates, and WireGuard peers:

```bash
# Edit customer-config.sh to add/change domains or peer settings
nano customer-config.sh

# Apply changes
./scripts/onboard.sh
```

**What `onboard.sh` does:**
1. Loads and validates settings from `customer-config.sh`
2. Auto-derives certificate fields (`CERT_DNS_NAMES`, `CERT_ORGANIZATION`, `CERT_COMMON_NAME`) the same way `install.sh` does
3. Updates `.env` with current domain, certificate, and WireGuard settings
4. Generates S/MIME key + CSR (skips if already exists, use `--regenerate-cert` to force)
   - The CSR is submitted to the CA via the WireGuard tunnel (90-second timeout)
   - If submission fails (tunnel not ready), a warning is printed and the script continues — services remain running
5. Sets up or updates the WireGuard peer connection in the database (runs `idagent-init`)
6. Restarts affected services (postfix-relay, mxengine, idagent)

**Exit codes:**
- `0` — Everything succeeded
- `1` — Fatal error (missing config, etc.)
- `2` — Partial success (services running, but certificate issuance failed — retry later)

**Adding a new domain:**
1. Edit `customer-config.sh` — add domain to `MAIL_DOMAINS` (comma-separated):
   ```bash
   MAIL_DOMAINS="example.com,example.org"
   ```
2. Run `./scripts/onboard.sh`
3. The script updates Postfix routing, regenerates certificate SANs (if auto-derived), and restarts services

**Regenerating certificates:**
```bash
./scripts/onboard.sh --regenerate-cert
```

### Step 5: WireGuard Peer Registration

After installation, the S/MIME certificate issuance will fail if your Stargate instance is not yet registered as a WireGuard peer on the HIN CA side. This is the most common issue during initial setup.

**What you need to provide to HIN:**

1. **WireGuard public key** - extract from idagent logs:
   ```bash
   docker compose logs idagent | grep "public key"
   ```
2. **`DEPLOYMENT_NAME`** - from your `customer-config.sh`
3. **`SERVER_STATIC_IP`** - the public IP of your Stargate server
4. **`WG_INTERFACE_PORT`** - only if you changed it from the default `19818`

Send these values to HIN so they can register your peer on the CA side.

**After HIN confirms your peer is registered:**

Restart the services and regenerate the certificate:

```bash
./scripts/onboard.sh --regenerate-cert
```

This restarts services (including idagent), which triggers a new WireGuard handshake. Since the CA now has your keys, the tunnel should establish and the certificate should be issued.

**To verify the tunnel before requesting the certificate:**

```bash
# Restart just idagent
docker compose restart idagent

# Check for successful WireGuard handshake
docker compose logs idagent 2>&1 | grep -i "handshake\|peer"
```

> **Also check your firewall**: Port `19818/TCP` must be open **both inbound and outbound** on the Stargate server.

### Subsequent Starts (after reboot)

```bash
./scripts/start.sh
```

The start script:
1. Starts infrastructure services
2. Unseals Vault using stored keys
3. Starts application services

### Stop Services

```bash
./scripts/stop.sh
```

This stops containers but preserves all data.

## Data Persistence

All data is stored in Docker volumes and **persists across restarts**.

| Service | Volume | Data |
|---------|--------|------|
| PostgreSQL | `postgres_data` | All databases (smimekeys, policy, idagent, mxengine) |
| Vault | `vault_data` | Encryption keys, secrets, S/MIME keys |
| MinIO | `minio_data` | Object storage (messages, attachments) |
| Postfix | `postfix_spool` | Mail queue |

### Safe Operations (data preserved)

```bash
# Stop and start - data safe
./scripts/stop.sh
./scripts/start.sh

# Or using docker compose directly
docker compose down      # Stops containers, KEEPS volumes
docker compose up -d     # Restarts containers
./scripts/start.sh       # Unseals Vault
```

### Vault Sealing Behavior

**Vault becomes sealed** when its container restarts. This is a security feature.

After any restart, run `./scripts/start.sh` to unseal Vault. The script uses the keys stored in `secrets/vault-keys.json`.

### Destructive Operations (data deleted)

These commands **DELETE ALL DATA** - use with caution:

```bash
# Delete everything (volumes, secrets, config)
./scripts/stop.sh --purge

# Or manually remove volumes
docker compose down -v   # The -v flag removes volumes!
```

## Scripts Reference

| Script | Purpose |
|--------|--------|
| `install.sh` | First-time installation (Docker, Vault, then calls `onboard.sh`) |
| `onboard.sh` | Domain onboarding (S/MIME key, WireGuard peer, mail domains, service restart) |
| `start.sh` | Start services and unseal Vault |
| `stop.sh` | Stop containers (data preserved) |
| `backup.sh` | Full backup (database, Vault keys, config, certificates) |
| `restore.sh` | Restore from backup archive (works on fresh machine) |
| `purge.sh` | Delete ALL data (requires confirmation) |
| `health-check.sh` | Comprehensive health check of all services (exit 0 = healthy, 1 = failures) |
| `init-vault.sh` | Vault initialization (used by `vault-init` container, not called directly) |
| `init-idagent.sh` | WireGuard peer connection setup (used by `idagent-init` container, not called directly) |
| `gather-app-versions.sh` | Collects app versions from `/liveness` endpoints for node-exporter (runs in `version-collector` container) |

## Configuration Files

| File | Purpose |
|------|---------|
| `customer-config.example` | Template for customer settings (copy to `customer-config.sh`) |
| `customer-config.sh` | Customer-specific settings (created from template, fill in before install) |
| `.env` | Generated environment file (created by `install.sh`, updated by `onboard.sh`) |
| `secrets/vault-keys.json` | Vault unseal keys and root token (back up securely!) |
| `secrets/signing-key.csr` | Generated CSR for S/MIME certificate |

## Backups

### Automatic Backups
- Daily backups run at 2:00 AM via cron (set up during install)
- Backups stored in `./backups/` as timestamped `.tar.gz` files
- Old backups (>7 days) are automatically cleaned up

### What's Included in Backups
- **Full PostgreSQL dump** (all databases with users and permissions)
- **Individual database dumps** (for partial restore if needed)
- **Vault keys** (`vault-keys.json` for unsealing)
- **Customer configuration** (`customer-config.sh` with WireGuard key)
- **S/MIME CSR and certificates** (any `.crt`, `.pem`, `.cer` files)
- **Backup manifest** (`manifest.json` with metadata)

### Manual Backup

```bash
./scripts/backup.sh
```

Creates a compressed archive in `./backups/YYYYMMDD_HHMMSS.tar.gz`.

### Restore from Backup

To restore on a **new machine** or after a **purge**:

```bash
# Copy the backup archive to the new machine, then:
./scripts/restore.sh backups/20260130_143022.tar.gz
```

The restore script will:
1. Stop any running services
2. Extract and validate the backup
3. Install Docker if needed
4. Restore customer configuration
5. Start infrastructure services (PostgreSQL, Vault, MinIO)
6. Restore the database
7. Unseal Vault with backed-up keys
8. Start application services

### Partial Restore (single database)

If you only need to restore one database:

```bash
# Extract backup
tar -xzf backups/20260130_143022.tar.gz -C /tmp/

# Restore a specific database
cat /tmp/20260130_143022/database/mxengine.sql | docker exec -i stargate-postgres psql -U postgres -d mxengine
```

## Updating Stargate

### Update Deployment Scripts and Configuration

The Stargate deployment repository receives updates to scripts (`onboard.sh`, `start.sh`, `health-check.sh`, etc.), configuration templates, and documentation. To apply these updates:

```bash
# 1. Create a backup before updating
./scripts/backup.sh

# 2. Pull the latest changes from the repository
git pull

# 3. Restart services to pick up any script or config changes
./scripts/stop.sh
./scripts/start.sh
```

> **Note**: `git pull` will not overwrite your `customer-config.sh`, `.env`, or `secrets/` directory - these are in `.gitignore`. If you have local changes to tracked files (e.g. `docker-compose.yml`), git will warn you. In that case, stash your changes first with `git stash`, pull, then re-apply with `git stash pop`.

If the update includes changes to `customer-config.sh.template`, compare it with your existing config to see if new variables were added:

```bash
diff customer-config.sh customer-config.sh.template
```

### Update Service Images

#### Update a Single Service

Edit the version in `.env`, then pull and recreate:

```bash
# Edit version in .env
sed -i 's/MXENGINE_VERSION=.*/MXENGINE_VERSION=v0.0.31/' .env

# Pull new image and recreate the service
docker compose pull mxengine
docker compose up -d --force-recreate mxengine
```

#### Quick Test (without editing .env)

Override the version directly:

```bash
MXENGINE_VERSION=v0.0.31 docker compose up -d --force-recreate mxengine
```

#### Update Multiple Services

```bash
# Edit versions in .env, then:
docker compose pull smimekeys-client policy idagent mxengine
docker compose up -d --force-recreate smimekeys-client policy idagent mxengine
```

#### Update All Services

```bash
# Pull all latest images
docker compose pull

# Recreate all services
docker compose up -d --force-recreate
```

#### Cleanup Old Images

After updates, remove unused images to free disk space:

```bash
docker image prune -f
```

#### Rollback

To rollback, edit `.env` to the previous version and recreate:

```bash
sed -i 's/MXENGINE_VERSION=.*/MXENGINE_VERSION=v0.0.30/' .env
docker compose up -d --force-recreate mxengine
```

## Configuration

The `.env` file is automatically generated by `install.sh` from `customer-config.sh`. Domain, certificate, and WireGuard settings are updated by `onboard.sh`. To customize, edit `customer-config.sh` and re-run the appropriate script.

Key sections in the generated `.env`:

```env
# PostgreSQL (auto-generated if empty in customer-config.sh)
POSTGRES_USER=postgres
POSTGRES_PASSWORD=<auto-generated>

# Vault (auto-populated after initialization)
VAULT_TOKEN=<auto-generated>

# MinIO (auto-generated if empty in customer-config.sh)
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=<auto-generated>

# Application Versions
SMIMEKEYS_VERSION=v0.0.5
POLICY_VERSION=v0.0.5
IDAGENT_VERSION=v0.0.6-branch
MXENGINE_VERSION=v0.0.35

# Mail Configuration
MAIL_DOMAINS=example.com
MAIL_HOSTNAME=mail.example.com
MXENGINE_PUBLIC_ADDRESS=http://203.0.113.50:8084
OUTBOUND_SEALER_MX_DOMAIN=hintest.ch

# WireGuard
WG_LOCAL_IP=203.0.113.50
WG_INTERFACE_PORT=19818
WG_TRANSPORT_MODE=tcp
```

> **Do not edit `.env` directly.** Changes will be overwritten by `onboard.sh`. Always edit `customer-config.sh` instead.

## Service URLs

| Service | URL/Port |
|---------|----------|
| smimekeys-client | http://localhost:8081 |
| policy | http://localhost:8082 |
| idagent | http://localhost:8083 |
| mxengine HTTP | http://localhost:8084 |
| mxengine SMTP | localhost:1587 |
| Postfix SMTP | localhost:25 |
| Postfix Reinjection | localhost:10026 (internal) |
| Vault UI | http://localhost:8200 |
| MinIO Console | http://localhost:9001 |
| PostgreSQL | localhost:5432 |

## Health Checks

All services expose a `/liveness` endpoint:

```bash
curl http://localhost:8081/liveness  # smimekeys-client
curl http://localhost:8082/liveness  # policy
curl http://localhost:8083/liveness  # idagent
curl http://localhost:8084/liveness  # mxengine
```

## Monitoring

### Prometheus Metrics

All application services expose Prometheus metrics on port 2112 (internally), mapped to different host ports:

| Service | Metrics Port | Metrics URL |
|---------|--------------|-------------|
| smimekeys-client | 2113 | http://localhost:2113/metrics |
| idagent | 2114 | http://localhost:2114/metrics |
| policy | 2115 | http://localhost:2115/metrics |
| mxengine | 2116 | http://localhost:2116/metrics |
| node-exporter | 9100 | http://localhost:9100/metrics |

### Prometheus Scrape Config Example

```yaml
scrape_configs:
  - job_name: 'stargate-smimekeys'
    static_configs:
      - targets: ['<host>:2113']
  - job_name: 'stargate-idagent'
    static_configs:
      - targets: ['<host>:2114']
  - job_name: 'stargate-policy'
    static_configs:
      - targets: ['<host>:2115']
  - job_name: 'stargate-mxengine'
    static_configs:
      - targets: ['<host>:2116']
  - job_name: 'stargate-node'
    static_configs:
      - targets: ['<host>:9100']
```

### Quick Metrics Check

```bash
# Check all metrics endpoints
curl -s http://localhost:2113/metrics | head -20  # smimekeys-client
curl -s http://localhost:2114/metrics | head -20  # idagent
curl -s http://localhost:2115/metrics | head -20  # policy
curl -s http://localhost:2116/metrics | head -20  # mxengine
curl -s http://localhost:9100/metrics | head -20  # node-exporter
```

### Log Collection (Promtail → Loki)

Promtail collects logs from application containers and ships them to Loki.

**Containers monitored:**
- stargate-smimekeys-client
- stargate-policy
- stargate-idagent
- stargate-mxengine

**Configuration** in `.env`:

```env
# Loki push URL
LOKI_URL=https://loki.infra.vereign-cdn.com

# Hostname label for logs (auto-set to DEPLOYMENT_NAME)
PROMTAIL_HOSTNAME=stargate-acme
```

**Labels added to logs:**
- `environment=<DEPLOYMENT_NAME>` - Identifies the deployment
- `host=<PROMTAIL_HOSTNAME>` - Identifies the host (same as deployment name)
- `container=<container-name>` - Container name
- `service=<service-name>` - Service name (e.g., smimekeys-client, policy)
- `level=<log-level>` - Extracted from JSON logs if available

**Query logs in Grafana:**

```logql
{environment="stargate-acme"} |= "error"
{environment="stargate-acme", service="mxengine"}
{environment="stargate-acme", level="error"}
```

**Verify Promtail is working:**

```bash
# Check Promtail status
docker logs stargate-promtail

# Check targets
curl -s http://localhost:9080/targets
```

**Note:** The VM's public IP must be whitelisted in Loki's ingress configuration.

## Postfix Relay

The Postfix relay container automatically configures itself from DNS records and integrates with mxengine for mail processing.

### Mail Flow Architecture

```
External Mail Server
         │
         ▼ (port 25)
┌─────────────────────────────────────────────────────┐
│ Postfix Relay (stargate-postfix-relay)              │
│                                                     │
│  Port 25 (main listener)                            │
│    │                                                │
│    ▼                                                │
│  content_filter = smtp:[mxengine]:1587              │
│    │                                                │
└────┼────────────────────────────────────────────────┘
     │
     ▼ (port 1587)
┌─────────────────────────────────────────────────────┐
│ MXEngine (stargate-mxengine)                        │
│                                                     │
│  Port 1587 (SMTP input)                             │
│    │                                                │
│    ▼                                                │
│  Sign/encrypt/process mail                          │
│    │                                                │
│    ▼                                                │
│  Deliver back to Postfix for relay                  │
│    │                                                │
└────┼────────────────────────────────────────────────┘
     │
     ▼ (port 10026)
┌─────────────────────────────────────────────────────┐
│ Postfix Relay (stargate-postfix-relay)              │
│                                                     │
│  Port 10026 (reinjection listener)                  │
│    │                                                │
│    ▼                                                │
│  transport_maps → relay to destination MX           │
│    │                                                │
└────┼────────────────────────────────────────────────┘
     │
     ▼ (port 25)
Destination Mail Server (via MX lookup)
```

**Seal callback flow (inbound):** When a remote sealer needs to deliver a sealed message, it calls `MXENGINE_PUBLIC_ADDRESS` (default: `http://<SERVER_STATIC_IP>:8084`). This is why port 8084 must be open for inbound traffic. The `http://` protocol is correct — TLS is not required because the seal payload is already encrypted.

### Configuration

Set `MAIL_DOMAINS` in your `customer-config.sh`:

```bash
# Required: Your mail domain(s), comma-separated for multiple
MAIL_DOMAINS=example.com

# Multiple domains:
MAIL_DOMAINS=example.com,example.org
```

The container will (for each domain):
1. Look up **MX records** to find the relay destination (where to deliver processed mail)
2. Parse **SPF records** recursively to find allowed sender networks (which IPs may send mail via port 25)
3. Auto-detect Docker networks for the port 10026 listener
4. Configure `content_filter` to route incoming mail through mxengine
5. Set up transport maps to relay processed mail to the destination MX

### Mail Routing (Migrating from Old MGW)

> **Key difference from the old HIN-MGW**: In the old MGW, you had to manually configure a target server per domain. In Stargate, Postfix **automatically discovers** where to deliver mail by looking up the MX records of each domain in DNS. Manual per-domain routing is also available via `DOMAIN_RELAY_MAP` if needed (see below).

**How it works:**

When the Stargate Postfix container starts, it queries the DNS MX records for each domain listed in `MAIL_DOMAINS`. It filters out its own hostname and uses the remaining MX entries as the delivery target. So for each domain, Postfix knows exactly which Exchange server to forward the processed mail to - based purely on DNS.

**What you need to do:**

For each of your domains, make sure there is an MX record in DNS pointing to the corresponding Exchange (or other mail) server:

```
domain1.com    MX 10  exchange1.domain1.com
domain2.com    MX 10  exchange2.domain2.com
domain3.com    MX 10  exchange3.domain3.com
```

This works for any number of domains - each domain can point to a different mail server, and Postfix will route accordingly.

**If Stargate is the only MX record** for a domain, Postfix will filter it out and have no delivery target. In that case, add a second MX record pointing to your mail server. Give Stargate a higher priority number (= lower priority) so it acts as the inbound gateway, and give your mail server a lower number (= higher priority) so Postfix uses it as the delivery target:

```
example.com    MX 10  exchange.example.com      ← delivery target (mail server)
example.com    MX 20  stargate.example.com      ← inbound gateway (Stargate)
```

**Alternative - single relay for all domains:**

If all your domains deliver to the same mail server, you can use `RELAYHOST` in `customer-config.sh` instead of MX records:

```bash
RELAYHOST=[smtp.office365.com]
```

> **Note**: `RELAYHOST` sends **all** mail to a single host and does not support per-domain routing. For setups with multiple domains and different mail servers, use `DOMAIN_RELAY_MAP` or the MX-based approach.

**Alternative - explicit per-domain relay mapping:**

If you prefer not to manage MX record priorities, you can configure explicit per-domain relay targets in `customer-config.sh`:

```bash
DOMAIN_RELAY_MAP="domain1.ch:[exchange1.domain1.ch]:25,domain2.ch:[exchange2.domain2.ch]:25"
```

Each entry maps a domain to a specific relay host and port. Domains not listed fall back to `RELAYHOST` (if set) or MX lookup. This is useful for setups with many domains routed to different Exchange servers.

**Precedence** (highest to lowest):
1. `DOMAIN_RELAY_MAP` - explicit per-domain target (if the domain is listed)
2. `RELAYHOST` - global fallback for all unmapped domains
3. MX lookup - automatic discovery from DNS (default)

**After updating MX records**, restart the Postfix container so it picks them up:

```bash
docker compose restart postfix-relay
```

### Ports

| Port | Purpose |
|------|---------|
| 25 | Main SMTP listener (external connections) |
| 10026 | Reinjection port (mxengine → postfix, internal only) |
| 1587 | MXEngine SMTP input (postfix → mxengine, internal only) |

### Manual Overrides

If DNS lookups fail or you need custom configuration:

```bash
# Skip MX lookup - specify relay host directly (all domains use the same host)
RELAYHOST=[smtp.office365.com]

# Per-domain relay targets (overrides MX lookup for listed domains)
DOMAIN_RELAY_MAP="domain1.ch:[exchange1.domain1.ch]:25,domain2.ch:[exchange2.domain2.ch]:25"

# Skip SPF lookup - specify allowed networks directly
POSTFIX_MYNETWORKS=10.0.0.0/8 172.16.0.0/12 192.168.0.0/16
```

> **Using Exchange?** See [Exchange-integration.md](Exchange-integration.md) for the full Exchange Online / On-Premises connector and transport rule setup.

### Verification

```bash
# Check Postfix status
docker exec stargate-postfix-relay postfix status

# View main configuration
docker exec stargate-postfix-relay postconf | grep -E 'relayhost|mynetworks|relay_domains|content_filter'

# View transport maps
docker exec stargate-postfix-relay postconf transport_maps
docker exec stargate-postfix-relay postmap -q '*' hash:/etc/postfix/transport

# Check master.cf (port 10026 listener)
docker exec stargate-postfix-relay grep -A5 "10026" /etc/postfix/master.cf

# Check logs
docker logs stargate-postfix-relay

# Test connection to port 25
telnet localhost 25

# Test internal port 10026 (from mxengine container)
docker exec stargate-mxengine nc -zv postfix-relay 10026
```

### Rebuild After Changes

If you modify `wrapper.sh` or `Dockerfile`:

```bash
docker compose build postfix-relay
docker compose up -d postfix-relay
```

### Troubleshooting

**Mail not being processed by mxengine**:
- Check content_filter is set: `docker exec stargate-postfix-relay postconf content_filter`
- Should show: `content_filter = smtp:[mxengine]:1587`
- Verify mxengine is reachable: `docker exec stargate-postfix-relay nc -zv mxengine 1587`

**Mail stuck after mxengine processing**:
- Check mxengine outbound config: OUTBOUND_SMTP_HOST=postfix-relay, OUTBOUND_SMTP_PORT=10026
- Verify port 10026 listener: `docker exec stargate-postfix-relay ss -tlnp | grep 10026`
- Check mynetworks on port 10026 includes Docker network (172.x.x.x/16)

**Greylisting errors (450 4.7.1)**:
- This is normal! The destination server is temporarily rejecting mail
- Postfix automatically retries after ~5 minutes
- Check queue: `docker exec stargate-postfix-relay mailq`

**Microsoft blocking IP (S3140)**:
- Your server's IP has poor reputation with Microsoft
- Request delisting at: https://sender.office.com
- May take 24-48 hours to take effect

**DNS Lookup Failures**:
- Set `DNS_SERVER=8.8.8.8` to use a specific DNS server
- Use `RELAYHOST` and `POSTFIX_MYNETWORKS` to skip DNS lookups

**Connection Refused on port 25**:
- Ensure port 25 is not blocked by firewall
- Check if another service is using port 25: `ss -tlnp | grep :25`

## WireGuard (Agent-to-Agent Communication)

IDAgent uses WireGuard to establish secure encrypted tunnels between Stargate instances for delivering sealed messages.

### How It Works

Each Stargate instance uses its server's real static public IP as the WireGuard tunnel address. This guarantees uniqueness across all deployments without manual coordination.

```
┌──────────────────────────────────────────┐       ┌──────────────────────────────────────────┐
│ Your Stargate (203.0.113.50)             │       │ HIN Test (5.102.144.182)                 │
│                                          │       │                                          │
│  IDAgent (203.0.113.50:19818)            │◄─────►│  IDAgent (5.102.144.182:19818)            │
│     │                                    │  WG   │     │                                    │
│     ▼                                    │ Tunnel│     ▼                                    │
│  Sealed message delivery via WG tunnel   │ (TCP) │  Receive sealed message                  │
│                                          │       │                                          │
└──────────────────────────────────────────┘       └──────────────────────────────────────────┘
```

### Configuration

WireGuard settings in `customer-config.sh`:

```bash
# ==============================================================================
# Server IP — used as WireGuard tunnel address and MXEngine callback URL
# ==============================================================================
SERVER_STATIC_IP="203.0.113.50"       # Your server's real static public IP

# ==============================================================================
# WireGuard local settings (typically left at defaults)
# ==============================================================================
WG_PRIVATE_KEY=""                     # Auto-generated by IDAgent, then saved back to config
WG_INTERFACE_PORT="19818"             # Default WireGuard port
WG_TRANSPORT_MODE="tcp"               # "tcp" (default) or "udp"

# ==============================================================================
# WireGuard peer (pre-filled for HIN Test — override for a different peer)
# ==============================================================================
WG_PEER_NAME="hin-test"
WG_PEER_PUBLIC_KEY="ol2zlG40M7+Rn81V9RUFmkIQV2ILLmEJHZww7HfoLxA="
WG_PEER_ENDPOINT="5.102.144.182:19818"
WG_PEER_IP="5.102.144.182"            # Peer's WireGuard tunnel address
WG_PEER_PORT="9090"                   # Peer's HTTP API port (over the tunnel)
WG_PEER_ALLOWED_IPS="5.102.144.182/32"
WG_PEER_EXTERNAL_ID="hintest.ch"      # Used for routing decisions
WG_PEER_DESCRIPTION="Connection to HIN Test IDAgent"
```

> **`WG_LOCAL_IP`** is auto-derived from `SERVER_STATIC_IP`. You do not need to set it separately.

> **`WG_PEER_IP`** vs **`WG_PEER_PORT`**: `WG_PEER_IP` is the remote peer's tunnel address (used for WireGuard routing). `WG_PEER_PORT` is the HTTP port the remote IDAgent listens on for API calls over the tunnel (default `9090`). These are independent values.

### Peer Connection Setup

The WireGuard peer connection is managed by `onboard.sh` (which runs the `idagent-init` container). The `customer-config.example` template comes with HIN Test peer defaults pre-filled, so the connection is set up automatically during `install.sh`.

The `idagent-init` container:

1. Waits for IDAgent to start and generate its WireGuard keypair
2. Open the logs of the IDAgent `docker compose logs idagent` and copy the `wireguard public key:` value example: `V2Qvr...IB1A2wQCApmHY=`
3. Get the public IP address for this machine
4. Get the domain name
5. The information from step 2, 3 and 4 should be provided to Vereign (kalin.canov@vereign.com)
6. For any **other** connection you would like to establish, through the Wireguard tunnel, you will need to provide to the other party the information from step 2, 3 and 4, and also receive/store their info. To store new peer after you received the info you should run the following curl command
```bash
curl --location 'localhost:8083/v1/connections' \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
--data '{
  "allowedIps": "<IP of new peer>/32",
  "description": "<short description>",
  "endpoint": "<IP of new peer>:19818",
  "externalId": [
    "<domain of new peer>"
  ],
  "name": "<Name of new peer>",
  "presharedKey": "",
  "publicKey": "<public key of new peer>",
  "status": "completed",
  "transport": "tcp",
  "wireguardIp": "<IP of new peer>",
  "wireguardPort": 10080
}'
```

### Verification

```bash
# Check IDAgent WireGuard interface
docker exec stargate-idagent wg show

# Check connection in database
docker exec stargate-postgres psql -U postgres -d idagent \
  -c "SELECT connection_id, name, endpoint, wireguard_ip, transport, status FROM connections;"

# Check connection external IDs (used for routing)
docker exec stargate-postgres psql -U postgres -d idagent \
  -c "SELECT connection_id, external_id FROM connection_external_ids;"

# Test WireGuard connectivity (check tunnel status from host)
docker logs stargate-idagent 2>&1 | grep -i "handshake\|peer.*added\|started listening"

# Check IDAgent logs for tunnel activity
docker logs stargate-idagent | grep -i wireguard
```

### Troubleshooting

**No WireGuard interface:**
- Check IDAgent logs: `docker logs stargate-idagent`
- Verify `WG_LOCAL_IP` is set in `.env` (auto-derived from `SERVER_STATIC_IP` — should be this server's static public IP)

**Peer not reachable:**
- Verify remote endpoint is accessible: `nc -zv <endpoint_host> <endpoint_port>`
- Check firewall allows TCP+UDP port 19818
- Verify public keys match on both ends
- If TCP has issues, try setting `WG_TRANSPORT_MODE="udp"` in customer-config.sh

**Connection not in database:**
- Run idagent-init manually: `docker compose run --rm idagent-init`
- Check idagent-init logs: `docker logs stargate-idagent-init`

## Policy Sync

The `policy-sync` service automatically syncs OPA/Rego policies from a Git repository to the PostgreSQL database.

### How It Works

```
┌─────────────────────┐      ┌─────────────────────┐      ┌─────────────────────┐
│ Git Repository      │      │ policy-sync         │      │ PostgreSQL          │
│                     │      │                     │      │                     │
│ policies/           │─────►│ Clone/Pull repo     │─────►│ policy database     │
│   alpha/            │      │ Parse .rego files   │      │ policies table      │
│   outbound/         │      │ Upsert to database  │      │                     │
│   ...               │      │ (runs every 1h)     │      │                     │
└─────────────────────┘      └─────────────────────┘      └─────────────────────┘
```

### Configuration

Settings in `customer-config.sh`:

```bash
# Git repository containing policies (pre-configured with HIN Stargate policies)
POLICY_SYNC_REPO_URL="https://github.com/Health-Info-Net-AG/Stargate-policies.git"

# Optional: Authentication for private repos
POLICY_SYNC_REPO_USER=""
POLICY_SYNC_REPO_PASS=""

# Optional: Specific branch (default: main)
POLICY_SYNC_REPO_BRANCH=""

# Optional: Subfolder within repo containing policies
POLICY_SYNC_REPO_FOLDER=""

# Sync interval (default: 1h)
POLICY_SYNC_INTERVAL="1h"
```

### Verification

```bash
# Check policy-sync status
docker logs stargate-policy-sync

# View synced policies
docker exec stargate-postgres psql -U postgres -d policy \
  -c "SELECT name, policy_group, filename, to_timestamp(updated_at) as updated FROM policies ORDER BY name;"

# View specific policy content
docker exec stargate-postgres psql -U postgres -d policy \
  -c "SELECT rego FROM policies WHERE name='deliveryStrategy' AND policy_group='alpha';"
```

### Manual Trigger

To force an immediate sync:

```bash
docker restart stargate-policy-sync
```

## Vault

### Access Vault UI
1. Open http://localhost:8200
2. Use the root token from `secrets/vault-keys.json` or `.env` file

### Vault Mounts
The following KV-v2 secret engines are created:
- `secret-smimekeys-client`
- `secret-policy`
- `secret-idagent`
- `secret-mxengine`

### Manual Vault Operations

```bash
# Check status
docker exec stargate-vault vault status

# List mounts
docker exec -e VAULT_TOKEN=<token> stargate-vault vault secrets list

# Write a secret
docker exec -e VAULT_TOKEN=<token> stargate-vault vault kv put secret-smimekeys-client/test key=value
```

## Databases

PostgreSQL databases created:
- `smimekeys_client`
- `policy`
- `idagent`
- `mxengine`

### Connect to PostgreSQL

```bash
docker exec -it stargate-postgres psql -U postgres

# Or connect externally
psql -h localhost -U postgres -d smimekeys_client
```

## Policies (Rego)

MXEngine uses OPA/Rego policies stored in PostgreSQL to determine mail delivery strategy.

**Recommended:** Use `policy-sync` to automatically sync policies from a Git repository. See [Policy Sync](#policy-sync) section.

### View Current Policy

```bash
# List all policies
docker exec stargate-postgres psql -U postgres -d policy \
  -c "SELECT id, name, policy_group, filename, to_timestamp(updated_at) as updated FROM policies;"

# View policy content
docker exec stargate-postgres psql -U postgres -d policy \
  -c "SELECT rego FROM policies WHERE name='deliveryStrategy';"
```

### Policy Location

- **MXEngine config:** `POLICY_OUTBOUND: "outbound/delivery"`
- **Database:** `policy` database, `policies` table
- **Managed by:** `policy-sync` service (syncs from Git repository)

## Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f smimekeys-client
docker compose logs -f vault
```

## Troubleshooting

### Certificate issuance failed / WireGuard tunnel not established

This is the most common issue after initial installation. The S/MIME certificate cannot be issued because the WireGuard tunnel to the HIN CA is not established.

**Symptoms:**
- `onboard.sh` shows: `⚠ Certificate issuance failed (WireGuard tunnel may not be established yet)`
- smimekeys-client logs show: `issue certificate error: certcatunnel: error sending request: idagent: ... context deadline exceeded`

**Root causes (check in order):**

1. **Peer not registered on HIN CA** - Your WireGuard public key must be registered on the HIN side. Provide HIN with:
   ```bash
   # Get your WireGuard public key
   docker compose logs idagent | grep "public key"
   ```
   Along with your `DEPLOYMENT_NAME`, `SERVER_STATIC_IP`, and `WG_INTERFACE_PORT` (if changed from 19818).

2. **Firewall blocking port 19818** - Ensure `19818/TCP` is open both inbound and outbound on the Stargate server.

3. **Wrong `MAIL_HOSTNAME`** - If still set to `mail.example.com` (the template default), update it in `customer-config.sh`.

**After the issue is resolved:**
```bash
./scripts/onboard.sh --regenerate-cert
```

See [Step 5: WireGuard Peer Registration](#step-5-wireguard-peer-registration) for the full process.

### Vault is sealed after restart
Run the start script which handles unsealing:
```bash
./scripts/start.sh
```

### Cannot pull images
Login to the registry:
```bash
docker login registry.vereign.io
```

### Service won't start
Check logs:
```bash
docker compose logs <service-name>
```

### Reset everything
```bash
./scripts/purge.sh
./scripts/install.sh
```

## Files Structure

```
stargate/
├── docker-compose.yml      # Main compose file
├── .env                    # Environment variables (generated by install.sh)
├── customer-config.sh      # Customer-specific settings (copied from customer-config.example)
├── customer-config.example # Template for customer configuration
├── README.md               # This file
├── config/
│   ├── vault/
│   │   └── vault.hcl       # Vault configuration
│   ├── postfix/
│   │   ├── Dockerfile       # Postfix relay container build
│   │   └── wrapper.sh       # Postfix entrypoint script
│   └── promtail/
│       └── promtail-config.yaml  # Promtail log shipping config
├── init/
│   └── postgres/
│       └── 01-create-databases.sql
├── scripts/
│   ├── install.sh              # First-time installation
│   ├── onboard.sh              # Domain onboarding (run after install or to add domains)
│   ├── start.sh                # Start services + unseal Vault
│   ├── stop.sh                 # Stop containers (preserves data)
│   ├── backup.sh               # Full backup (DB, Vault, config, certs)
│   ├── restore.sh              # Restore from backup archive
│   ├── purge.sh                # Delete all data (destructive!)
│   ├── health-check.sh         # Comprehensive health check of all services
│   ├── init-vault.sh           # Vault initialization (used by vault-init container)
│   ├── init-idagent.sh         # WireGuard peer connection setup (used by idagent-init container)
│   └── gather-app-versions.sh  # Collects app versions for node-exporter metrics
├── secrets/                # Created on first run (gitignored)
│   ├── vault-keys.json     # Vault unseal keys (BACK THIS UP!)
│   └── signing-key.csr     # S/MIME certificate signing request
└── backups/                # Full backups (gitignored)
    └── *.tar.gz
```

## Quick Health & Log Checks

Run the comprehensive health check:

```bash
./scripts/health-check.sh

# With verbose output (shows WireGuard details, liveness responses):
./scripts/health-check.sh -v
```

This checks:
- All container statuses (running, healthy)
- Liveness endpoints (smimekeys-client, policy, idagent, mxengine)
- Vault seal status
- PostgreSQL connectivity and all 4 databases
- MinIO health
- WireGuard tunnel status and peer handshakes
- Postfix (running, port 25, port 10026, mail queue)
- Prometheus metrics endpoints
- Disk and memory usage

For manual log inspection:

```bash
# Check logs (last 10 lines)
docker logs stargate-smimekeys-client --tail 10
docker logs stargate-policy --tail 10
docker logs stargate-idagent --tail 10
docker logs stargate-mxengine --tail 10

# Follow logs in real-time
docker logs -f stargate-mxengine

# Check all container statuses
docker ps --format 'table {{.Names}}\t{{.Status}}'
```
