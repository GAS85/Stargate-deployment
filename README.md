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