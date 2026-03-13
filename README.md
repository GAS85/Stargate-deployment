# Stargate Deployment Instruction

### Alpha and Beta phase recommendations 

#### Alpha phase 

The alpha phase of HIN MWG is an early testing stage where most of the functionalities are built but still incomplete and may require improvements in processes and functionality.

Recommendations and Expectations for the Alpha Phase
* As HIN MGW is still under rapid development, you should expect periodic requests to update your instance.
* We recommend preparing and using a test domain, not a production domain, during the alpha phase.
* If you have a test environment available, please perform the initial installation there and connect it to a test email system.
* Please do not use real production traffic before the official production release date. Routing production traffic during the alpha phase is done at your own risk.
  * During the Alpha and Beta testing phases, you are allowed to register any test domain you own. During the onboarding process, a CSR request will be sent to the HIN Test CA server, and the certificate will be issued automatically. 

#### Beta phase 


## Services Included

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
- **Promtail** - Log collector for Loki (ships app logs)

## Quick Start

### Installation options 

* Docker installation https://code.vereign.com/svdh/stargate-deployment#prerequisites
* VM image installation
  * Azure VM image installation [ Azure-VM-image-install.md](https://code.vereign.com/svdh/stargate-deployment/-/blob/main/Azure-VM-image-install.md)
  * Windows 11 pro (Hyper-V) image installation [Windows11pro-image-install.md](https://code.vereign.com/svdh/stargate-deployment/-/blob/main/Windows11pro-image-install.md)
  * VMware image installation [VMware-image-install.md](https://code.vereign.com/svdh/stargate-deployment/-/blob/main/VMware-image-install.md)
  * Proxmox image installation [Proxmox-image-install.md](https://code.vereign.com/svdh/stargate-deployment/-/blob/main/Proxmox-image-install.md)
* HELM charts [helm-deploy.md](https://code.vereign.com/svdh/stargate-deployment/-/blob/main/helm-deploy.md)

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

Before installation, fill in the customer configuration file:

```bash
# Edit the customer config file
nano customer-config.sh
```

**Required settings:**
- `CUSTOMER_NAME` - Customer name for identification
- `DEPLOYMENT_NAME` - Unique deployment identifier (used in logs)
- `MAIL_DOMAINS` - Mail relay domains, comma-separated for multiple (e.g., `example.com` or `example.com,example.org`)
- `MXENGINE_PUBLIC_ADDRESS` - Publicly accessible URL for seal callbacks (e.g., `http://203.0.113.10:8084`)
- `OUTBOUND_SEALER_MX_DOMAIN` - Sealer MX domain for outbound seal delivery (e.g., `vereign-cdn.com`)
- `CERT_DNS_NAMES` - DNS names for S/MIME certificate
- `CERT_ORGANIZATION` - Organization name for certificate
- `CERT_COMMON_NAME` - Common name for certificate
- `CERT_COUNTRIES` - Country codes for certificate

**WireGuard local settings (for agent-to-agent communication):**
- `WG_PRIVATE_KEY` - WireGuard private key (auto-generated on first install, then saved to config)
- `WG_LOCAL_IP` - Local WireGuard IP (use this server's real static public IP to guarantee uniqueness)
- `WG_INTERFACE_PORT` - WireGuard port (default: 19818)
- `WG_TRANSPORT_MODE` - Transport protocol: `tcp` (default) or `udp`

**WireGuard peer settings (can be configured later, applied by `onboard.sh`):**
- `WG_PEER_PUBLIC_KEY` - Remote peer's WireGuard public key
- `WG_PEER_ENDPOINT` - Remote peer endpoint (host:port)
- `WG_PEER_IP` - WireGuard IP of remote peer
- `WG_PEER_PORT` - Communication port on remote peer
- `WG_PEER_EXTERNAL_ID` - External identifier (e.g., domain) for routing

**Optional settings (have defaults):**
- `POSTGRES_PASSWORD` - Auto-generated if empty
- `MINIO_ROOT_PASSWORD` - Auto-generated if empty
- `POLICY_SYNC_REPO_URL` - Git repo for policy sync (enables policy-sync service)

**Auto-generated (do not set manually):**
- `VAULT_TOKEN` - Generated by Vault during first initialization (saved to customer-config.sh)
- `WG_PRIVATE_KEY` - Generated by IDAgent on first run (saved to customer-config.sh)
- Application versions, advanced mail settings, etc.

### Step 2: Deploy to a Server

```bash
# Copy files to the server
scp -r docker-compose/* your-server:/path/to/stargate/

# SSH to server and install
ssh your-server "cd /path/to/stargate && chmod +x scripts/*.sh && ./scripts/install.sh"
```

### Step 3: What Install Does

The install script will:
1. Check for Docker/Docker Compose/jq and offer to install them if missing (Ubuntu)
2. Load and validate `customer-config.sh`
3. Generate `.env` file with all configuration (auto-generate passwords if not set)
4. Start infrastructure (PostgreSQL, Vault, MinIO)
5. Initialize Vault (create keys, unseal, create mounts)
6. Save Vault keys to `secrets/vault-keys.json`
7. Update `.env` with the Vault root token
8. Restart application services to pick up the token
9. Run initial onboarding (`onboard.sh --initial-setup`):
   - Generate S/MIME signing key and CSR
   - Save CSR to `secrets/signing-key.csr`
10. Set up daily backup cron job (runs at 2:00 AM)

### Step 4: Onboard Domains (Post-Install)

After initial installation, use `onboard.sh` to manage domains, certificates, and WireGuard peers:

```bash
# Edit customer-config.sh to add/change domains
nano customer-config.sh

# Apply changes
./scripts/onboard.sh
```

**What `onboard.sh` does:**
1. Loads settings from `customer-config.sh`
2. Updates `.env` with current domain and WireGuard settings
3. Generates S/MIME key + CSR (skips if already exists, use `--regenerate-cert` to force)
4. Sets up WireGuard peer connection (runs `idagent-init`)
5. Restarts affected services (postfix-relay, mxengine)

**Adding a new domain:**
1. Edit `customer-config.sh` — add domain to `MAIL_DOMAINS` (comma-separated):
   ```bash
   MAIL_DOMAINS="example.com,example.org"
   ```
2. Run `./scripts/onboard.sh`
3. The script updates routing and restarts services

**Regenerating certificates:**
```bash
./scripts/onboard.sh --regenerate-cert
```

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

## Scripts Reference

| Script | Purpose |
|--------|--------|
| `install.sh` | First-time infrastructure setup (Docker, Vault, then calls onboard.sh) |
| `onboard.sh` | Domain onboarding (S/MIME key, WireGuard peer, mail domains, service restart) |
| `start.sh` | Start services and unseal Vault |
| `stop.sh` | Stop containers (data preserved) |
| `backup.sh` | Full backup (database, Vault keys, config, certificates) |
| `restore.sh` | Restore from backup archive (works on fresh machine) |
| `purge.sh` | Delete ALL data (requires confirmation) |
| `health-check.sh` | Comprehensive health check of all services |
| `init-vault.sh` | Vault initialization (used by vault-init container) |
| `init-idagent.sh` | WireGuard peer connection setup (used by idagent-init container) |

## Configuration Files

| File | Purpose |
|------|---------|
| `customer-config.sh` | Customer-specific settings (fill in before install) |
| `.env` | Generated environment file (created by install.sh, updated by onboard.sh) |
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

## Updating Service Images

### Update a Single Service

Edit the version in `.env`, then pull and recreate:

```bash
# Edit version in .env
sed -i 's/MXENGINE_VERSION=.*/MXENGINE_VERSION=v0.0.31/' .env

# Pull new image and recreate the service
docker compose pull mxengine
docker compose up -d --force-recreate mxengine
```

### Quick Test (without editing .env)

Override the version directly:

```bash
MXENGINE_VERSION=v0.0.31 docker compose up -d --force-recreate mxengine
```

### Update Multiple Services

```bash
# Edit versions in .env, then:
docker compose pull smimekeys-client policy idagent mxengine
docker compose up -d --force-recreate smimekeys-client policy idagent mxengine
```

### Update All Services

```bash
# Pull all latest images
docker compose pull

# Recreate all services
docker compose up -d --force-recreate
```

### Cleanup Old Images

After updates, remove unused images to free disk space:

```bash
docker image prune -f
```

### Rollback

To rollback, edit `.env` to the previous version and recreate:

```bash
sed -i 's/MXENGINE_VERSION=.*/MXENGINE_VERSION=v0.0.30/' .env
docker compose up -d --force-recreate mxengine
```

## Configuration

The `.env` file is automatically generated by `install.sh` from `customer-config.sh`. Domain and WireGuard settings are updated by `onboard.sh`. Edit `customer-config.sh` to customize:

```env
# PostgreSQL
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres

# MinIO
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin123
S3_BUCKET_NAME=stargate-bucket

# Application versions
SMIMEKEYS_VERSION=latest
POLICY_VERSION=latest
IDAGENT_VERSION=latest
MXENGINE_VERSION=latest
```

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

# Hostname label for logs
PROMTAIL_HOSTNAME=stargate
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
External Mail Server (port 25)
         │
         ▼
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
     ▼
┌─────────────────────────────────────────────────────┐
│ MXEngine (stargate-mxengine)                        │
│                                                     │
│  Port 1587 (SMTP input)                             │
│    │                                                │
│    ▼                                                │
│  Sign/encrypt/process mail                          │
│    │                                                │
│    ▼                                                │
│  OUTBOUND_SMTP_HOST=${OUTBOUND_SMTP_HOST}          │
│  OUTBOUND_SMTP_PORT=${OUTBOUND_SMTP_PORT}           │
│    │                                                │
└────┼────────────────────────────────────────────────┘
     │
     ▼
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
     ▼
Destination Mail Server (via MX lookup)
```

### Configuration

Set `MAIL_DOMAINS` in your `customer-config.sh` (or `.env` file):

```bash
# Required: Your mail domain(s), comma-separated for multiple
MAIL_DOMAINS=example.com

# Multiple domains:
MAIL_DOMAINS=example.com,example.org
```

The container will (for each domain):
1. Look up MX records to find relay destination
2. Parse SPF records recursively to find allowed sender networks
3. Auto-detect Docker networks for the port 10026 listener
4. Configure content_filter to route mail through mxengine
5. Set up transport maps to relay processed mail to destination MX

### Ports

| Port | Purpose |
|------|---------|
| 25 | Main SMTP listener (external connections) |
| 10026 | Reinjection port (mxengine → postfix, internal only) |
| 1587 | MXEngine SMTP input (postfix → mxengine, internal only) |

### Manual Overrides

If DNS lookups fail or you need custom configuration:

```bash
# Skip MX lookup - specify relay host directly
RELAYHOST=[smtp.office365.com]

# Skip SPF lookup - specify allowed networks directly
POSTFIX_MYNETWORKS=10.0.0.0/8 172.16.0.0/12 192.168.0.0/16
```

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

```
┌─────────────────────────────────────────┐       ┌─────────────────────────────────────────┐
│ Stargate Instance A                     │       │ Stargate Instance B                     │
│                                         │       │                                         │
│  IDAgent (10.0.0.1:19818)               │◄─────►│  IDAgent (10.0.0.2:19818)               │
│     │                                   │  WG   │     │                                   │
│     ▼                                   │ Tunnel│     ▼                                   │
│  Sealed message delivery via WG tunnel  │       │  Receive sealed message                 │
│                                         │       │                                         │
└─────────────────────────────────────────┘       └─────────────────────────────────────────┘
```

### Configuration

WireGuard settings in `customer-config.sh`:

```bash
# Local WireGuard settings (this instance)
WG_PRIVATE_KEY=""               # Auto-generated, then saved back to config
WG_LOCAL_IP="203.0.113.50"       # Use server's real static public IP
WG_INTERFACE_PORT="19818"        # Default WireGuard port
WG_TRANSPORT_MODE="tcp"          # "tcp" (default) or "udp"

# Peer configuration (remote instance to connect to)
WG_PEER_NAME="remote-agent"                          # Human-readable name
WG_PEER_PUBLIC_KEY="WhTN0ekf/jT+wAv9kIIHmwMLPWr9Gv1MXxnvAkJKbHU="  # Remote's WG public key
WG_PEER_ENDPOINT="203.0.113.10:19818"                # Remote's public endpoint
WG_PEER_IP="10.0.0.2"                                # Remote's WireGuard IP
WG_PEER_PORT="9090"                                  # Communication port
WG_PEER_EXTERNAL_ID="example.com"                    # Used for routing decisions
```

**Important:** Each Stargate deployment *MUST HAVE A UNIQUE IP* in the WireGuard network. Best sync with Vereign to avoid IP conflicts.

### Peer Connection Setup

The WireGuard peer connection is set up by `onboard.sh` (which runs the `idagent-init` container). During initial install, peer setup is deferred — configure the peer settings in `customer-config.sh` and run `./scripts/onboard.sh` to establish the connection.

The `idagent-init` container:

1. Waits for IDAgent to generate its WireGuard keypair
2. Creates a connection entry in the `connections` table
3. Links the peer with endpoint, IP, and routing information

### Verification

```bash
# Check IDAgent WireGuard interface
docker exec stargate-idagent wg show

# Check connection in database
docker exec stargate-postgres psql -U postgres -d idagent \
  -c "SELECT connection_id, name, endpoint, wireguard_ip, transport, status FROM connections;"

# Check connection external IDs
docker exec stargate-postgres psql -U postgres -d idagent \
  -c "SELECT connection_id, external_id FROM connection_external_ids;"

# Test WireGuard connectivity (ping remote peer IP)
docker exec stargate-idagent ping -c 3 10.0.0.2

# Check IDAgent logs for tunnel activity
docker logs stargate-idagent | grep -i wireguard
```

### Troubleshooting

**No WireGuard interface:**
- Check IDAgent logs: `docker logs stargate-idagent`
- Verify `WG_LOCAL_IP` is set in `.env` (should be this server's static public IP)

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
# Git repository containing policies
POLICY_SYNC_REPO_URL="https://code.vereign.com/svdh/policies-public.git"

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
├── customer-config.sh      # Customer-specific settings
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
│   ├── install.sh          # First-time installation
│   ├── onboard.sh          # Domain onboarding (run after install or to add domains)
│   ├── start.sh            # Start services + unseal Vault
│   ├── stop.sh             # Stop containers (preserves data)
│   ├── backup.sh           # Full backup (DB, Vault, config, certs)
│   ├── restore.sh          # Restore from backup archive
│   ├── purge.sh            # Delete all data (destructive!)
│   ├── health-check.sh     # Comprehensive health check of all services
│   ├── init-vault.sh       # Vault initialization (used by container)
│   ├── init-idagent.sh     # WireGuard peer connection setup (used by container)
│   └── gather-app-versions.sh  # Collects app versions for node-exporter
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
