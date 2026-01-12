# SVDH Local Development Environment

Local Docker Compose setup for running SVDH services.

## Services Included

### Applications
- **smimekeys-client** - S/MIME keys client service (port 8081)
- **policy** - Policy service (port 8082)
- **idagent** - ID Agent service (port 8083)
- **mxengine** - MX Engine service (port 8084, SMTP: 1587)

### Infrastructure
- **PostgreSQL** - Database (port 5432)
- **Vault** - Secrets management (port 8200)
- **MinIO** - S3-compatible storage (API: 9000, Console: 9001)
- **Postfix Relay** - Mail relay server (port 25) - auto-configures from DNS

### Monitoring
- **node-exporter** - Host metrics for Prometheus (port 9100)
- **Promtail** - Log collector for Loki (ships app logs)

## Quick Start

### Prerequisites
- Ubuntu server (Docker will be installed automatically if missing)
- Access to `registry.vereign.io` (login with `docker login registry.vereign.io`)

### Deploying to a Server

```bash
# Copy files to the server
scp -r /home/petar/Repos/svdh/stargate-deployment/docker-compose/* stargate-demo:/root/stargate/

# SSH to server and install
ssh stargate-demo "cd /root/stargate && chmod +x scripts/*.sh && ./scripts/install.sh"
```

### First Time Setup (Local)

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Run installation
./scripts/install.sh
```

The install script will:
1. Check for Docker/Docker Compose/jq and offer to install them if missing (Ubuntu)
2. Create `.env` file from `.env.example` if it doesn't exist
3. Start infrastructure (PostgreSQL, Vault, MinIO)
4. Initialize Vault (create keys, unseal, create mounts)
5. Save Vault keys to `secrets/vault-keys.json`
6. Update `.env` with the Vault root token
7. Restart application services to pick up the token
8. Generate S/MIME signing key and CSR (prompts for certificate details)
9. Set up daily backup cron job (runs at 2:00 AM)

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

## Scripts Reference

| Script | Purpose |
|--------|--------|
| `install.sh` | First-time setup (Docker, Vault, S/MIME key, cron backup) |
| `start.sh` | Start services and unseal Vault |
| `stop.sh` | Stop containers (data preserved) |
| `backup.sh` | Manual PostgreSQL backup to `./backups/` |
| `purge.sh` | Delete ALL data (requires confirmation) |

## Backups

### Automatic Backups
- Daily backups run at 2:00 AM via cron (set up during install)
- Backups stored in `./backups/` as timestamped `.tar.gz` files
- Old backups (>7 days) are automatically cleaned up

### Manual Backup

```bash
./scripts/backup.sh
```

Creates a compressed archive of all PostgreSQL databases.

### Restore from Backup

```bash
# Extract backup
tar -xzf backups/20260109_020000.tar.gz -C backups/

# Restore a specific database
cat backups/20260109_020000/mxengine.sql | docker exec -i stargate-postgres psql -U postgres -d mxengine
```

## Configuration

The `.env` file is automatically created from `.env.example` on first run. Edit it to customize:

```env
# PostgreSQL
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres

# MinIO
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin123
S3_BUCKET_NAME=svdh-bucket

# Application versions
SMIMEKEYS_VERSION=latest
POLICY_VERSION=latest
IDAGENT_VERSION=latest
MXENGINE_VERSION=latest
```

## Service URLs

| Service | URL |
|---------|-----|
| smimekeys-client | http://localhost:8081 |
| policy | http://localhost:8082 |
| idagent | http://localhost:8083 |
| mxengine | http://localhost:8084 |
| mxengine SMTP | localhost:1587 |
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
LOKI_URL=https://loki.k8s.vereign-cdn.com

# Hostname label for logs
PROMTAIL_HOSTNAME=stargate
```

**Labels added to logs:**
- `environment=stargate-alpha` - Identifies the deployment
- `host=<PROMTAIL_HOSTNAME>` - Identifies the host
- `container=<container-name>` - Container name
- `service=<service-name>` - Service name (e.g., smimekeys-client, policy)
- `level=<log-level>` - Extracted from JSON logs if available

**Query logs in Grafana:**

```logql
{environment="stargate-alpha"} |= "error"
{environment="stargate-alpha", service="mxengine"}
{environment="stargate-alpha", level="error"}
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

The Postfix relay container automatically configures itself from DNS records:
- **MX records** → Determines where to relay mail (RELAYHOST)
- **SPF records** → Determines who can send through the relay (MYNETWORKS)

### How It Works

The container is built locally from `boky/postfix` with a wrapper script:

1. **Build phase** (`docker compose build postfix-relay`):
   - Pulls `boky/postfix:latest` as base image
   - Installs DNS utilities (`bind-tools`)
   - Adds `wrapper.sh` script as entrypoint

2. **Runtime** (on every container start):
   - `wrapper.sh` runs first and reads `MAIL_DOMAIN`
   - Performs MX lookup → sets `RELAYHOST` environment variable
   - Parses SPF records recursively → sets `MYNETWORKS` environment variable
   - Executes the original boky/postfix entrypoint with configured variables

DNS lookups happen fresh on every container restart, so configuration updates automatically if DNS records change.

### Configuration

Set `MAIL_DOMAIN` in your `.env` file:

```env
# Required: Your mail domain
MAIL_DOMAIN=example.com
```

The container will:
1. Look up MX records for `example.com` to find relay destination
2. Parse SPF records recursively to find allowed sender networks
3. Configure Postfix automatically

### Manual Overrides

If DNS lookups fail or you need custom configuration:

```env
# Skip MX lookup - specify relay host directly
RELAYHOST=[smtp.office365.com]

# Skip SPF lookup - specify allowed networks directly
POSTFIX_MYNETWORKS=10.0.0.0/8 172.16.0.0/12 192.168.0.0/16
```

### Verification

```bash
# Check Postfix status
docker exec stargate-postfix-relay postfix status

# View configuration
docker exec stargate-postfix-relay postconf | grep -E 'relayhost|mynetworks|relay_domains'

# Check logs
docker logs stargate-postfix-relay

# Test connection
telnet localhost 25
```

### Rebuild After Changes

If you modify `wrapper.sh` or `Dockerfile`:

```bash
docker compose build postfix-relay
docker compose up -d postfix-relay
```

### Troubleshooting

**DNS Lookup Failures**:
- Set `DNS_SERVER=8.8.8.8` to use a specific DNS server
- Use `RELAYHOST` and `POSTFIX_MYNETWORKS` to skip DNS lookups

**Connection Refused**:
- Ensure port 25 is not blocked by firewall
- Check if another service is using port 25: `ss -tlnp | grep :25`

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
docker exec svdh-vault vault status

# List mounts
docker exec -e VAULT_TOKEN=<token> svdh-vault vault secrets list

# Write a secret
docker exec -e VAULT_TOKEN=<token> svdh-vault vault kv put secret-smimekeys-client/test key=value
```

## Databases

PostgreSQL databases created:
- `smimekeys_client`
- `policy`
- `idagent`
- `mxengine`

### Connect to PostgreSQL

```bash
docker exec -it svdh-postgres psql -U postgres

# Or connect externally
psql -h localhost -U postgres -d smimekeys_client
```

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
├── .env                    # Environment variables (auto-created)
├── .env.example            # Template for .env
├── README.md               # This file
├── config/
│   └── vault/
│       └── vault.hcl       # Vault configuration
├── init/
│   └── postgres/
│       └── 01-create-databases.sql
├── policies/               # Rego policy files
│   └── alpha/
│       └── deliveryStrategy/
│           └── policy.rego
├── scripts/
│   ├── install.sh          # First-time installation
│   ├── start.sh            # Start services + unseal Vault
│   ├── stop.sh             # Stop containers (preserves data)
│   ├── backup.sh           # Manual database backup
│   ├── purge.sh            # Delete all data (destructive!)
│   ├── init-vault.sh       # Vault initialization (used by container)
│   └── init-policies.sh    # Policy initialization (used by container)
├── secrets/                # Created on first run (gitignored)
│   └── vault-keys.json     # Vault unseal keys (BACK THIS UP!)
└── backups/                # Database backups (gitignored)
    └── *.tar.gz
```

## Quick Health & Log Checks

```bash
# Check all liveness endpoints
echo "=== smimekeys-client ===" && curl -s http://localhost:8081/liveness && echo ""
echo "=== policy ===" && curl -s http://localhost:8082/liveness && echo ""
echo "=== idagent ===" && curl -s http://localhost:8083/liveness && echo ""
echo "=== mxengine ===" && curl -s http://localhost:8084/liveness && echo ""

# Check logs (last 10 lines)
echo "=== smimekeys-client logs ===" && docker logs stargate-smimekeys-client --tail 10
echo "=== policy logs ===" && docker logs stargate-policy --tail 10
echo "=== idagent logs ===" && docker logs stargate-idagent --tail 10
echo "=== mxengine logs ===" && docker logs stargate-mxengine --tail 10

# Follow logs in real-time
docker logs -f stargate-mxengine

# Check all container statuses
docker ps --format 'table {{.Names}}\t{{.Status}}'
```