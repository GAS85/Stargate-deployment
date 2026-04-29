### Applications

* **smimekeys-client** - S/MIME keys client service (port 8081)

* **policy** - Policy service (port 8082)
* **idagent** - ID Agent service (port 8083, WireGuard: 19818/tcp+udp)
* **mxengine** - MX Engine service (port 8084, SMTP: 1587)
* **policy-sync** - Syncs OPA/Rego policies from Git repository to database (runs continuously)

### Infrastructure

* **PostgreSQL** - Database (port 5432)

* **Vault** - Secrets management (port 8200)
* **MinIO** - S3-compatible storage (API: 9000, Console: 9001)
* **Postfix Relay** - Mail relay server (port 25) - auto-configures from DNS

### Init Containers

* **vault-init** - Initializes and unseals Vault on first run

* **idagent-init** - Creates WireGuard peer connection in idagent database

### Monitoring

* **node-exporter** - Host metrics for Prometheus (port 9100)

* **version-collector** - Collects app versions from `/liveness` endpoints for node-exporter
* **Promtail** - Log collector for Loki (ships app logs)
