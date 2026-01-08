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
- Docker and Docker Compose installed (from Docker's official repository)
- Access to `registry.vereign.io` (login with `docker login registry.vereign.io`)

### Installing Docker (Ubuntu)

```bash
# 1. Remove the Ubuntu docker.io package (if installed)
sudo apt remove docker.io docker-doc docker-compose podman-docker containerd runc

# 2. Set up Docker's official GPG key and repository
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 3. Install Docker Engine + Compose from Docker's repo
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin jq

# 4. Verify installation
docker --version
docker compose version
```

### Deploying to a Server

```bash
# Copy files to the server
scp -r /home/petar/Repos/svdh/stargate-deployment/docker-compose/* stargate-demo:/root/stargate/

# SSH to server and start
ssh stargate-demo "cd /root/stargate && chmod +x scripts/*.sh && ./scripts/start.sh"
```

### First Time Setup (Local)

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