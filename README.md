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
- Docker and Docker Compose installed
- Access to `registry.vereign.io` (login with `docker login registry.vereign.io`)

### First Time Setup

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Start everything
./scripts/start.sh
```

The start script will:
1. Start infrastructure (PostgreSQL, Vault, MinIO)
2. Initialize Vault (create keys, unseal, create mounts)
3. Save Vault keys to `secrets/vault-keys.json`
4. Update `.env` with the Vault root token
5. Start application services

### Subsequent Starts (after reboot)

```bash
./scripts/start.sh
```

The script detects existing Vault keys and automatically:
1. Starts infrastructure
2. Unseals Vault using stored keys
3. Starts application services

### Stop Services

```bash
./scripts/stop.sh

# Or to also remove all data (volumes):
docker compose down -v
```

## Configuration

Edit `.env` file to customize:

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
docker compose down -v
rm -rf secrets/
./scripts/start.sh
```

## Files Structure

```
svdh-local/
├── docker-compose.yml      # Main compose file
├── .env                    # Environment variables
├── README.md              # This file
├── config/
│   └── vault/
│       └── vault.hcl      # Vault configuration
├── init/
│   └── postgres/
│       └── 01-create-databases.sql
├── scripts/
│   ├── start.sh           # Start script (handles init/unseal)
│   ├── stop.sh            # Stop script
│   └── init-vault.sh      # Vault initialization (used by container)
└── secrets/               # Created on first run
    └── vault-keys.json    # Vault unseal keys (BACK THIS UP!)
```


# Check all liveness endpoints
curl -s http://localhost:8081/liveness  # smimekeys-client
curl -s http://localhost:8082/liveness  # policy
curl -s http://localhost:8083/liveness  # idagent
curl -s http://localhost:8084/liveness  # mxengine

# Check logs (last 10 lines)
docker logs stargate-smimekeys-client --tail 10
docker logs stargate-policy --tail 10
docker logs stargate-idagent --tail 10
docker logs stargate-mxengine --tail 10

# Follow logs in real-time
docker logs -f stargate-mxengine

# Check all container statuses
docker ps --format 'table {{.Names}}\t{{.Status}}'