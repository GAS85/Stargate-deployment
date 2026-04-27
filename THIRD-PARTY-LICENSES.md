# Third-Party Licenses

This document lists the licenses of third-party software components used in the Stargate (HIN MGW) deployment.

---

## Dozzle

- **Component:** Dozzle - Real-time Docker log viewer
- **Image:** `amir20/dozzle:v10.5.0`
- **License:** MIT License
- **Copyright:** Copyright (c) 2025 Amir Raminfar
- **Source:** https://github.com/amir20/dozzle
- **License Text:** https://github.com/amir20/dozzle/blob/master/LICENSE

---

## PostgreSQL

- **Component:** PostgreSQL Database Server
- **Image:** `postgres:18-alpine`
- **License:** PostgreSQL License (BSD-like)
- **Copyright:** Copyright (c) 1996-2024, The PostgreSQL Global Development Group
- **Source:** https://www.postgresql.org/about/licence/
- **License Text:** https://www.postgresql.org/about/licence/

---

## Prometheus Node Exporter

- **Component:** Prometheus Node Exporter - System metrics collector
- **Image:** `prom/node-exporter:latest`
- **License:** Apache License 2.0
- **Copyright:** Copyright The Prometheus Authors
- **Source:** https://github.com/prometheus/node_exporter
- **License Text:** https://github.com/prometheus/node_exporter/blob/main/LICENSE

---

## Grafana Promtail

- **Component:** Promtail - Log shipper for Grafana Loki
- **Image:** `grafana/promtail:latest`
- **License:** GNU Affero General Public License v3.0 (AGPL v3)
- **Copyright:** Copyright Grafana Labs
- **Source:** https://github.com/grafana/loki/tree/main/pkg/promtail
- **License Text:** https://github.com/grafana/loki/blob/main/LICENSE

---

## MinIO

- **Component:** MinIO - S3-compatible object storage
- **Image:** `minio/minio:latest`
- **License:** GNU Affero General Public License v3.0 (AGPL v3)
- **Copyright:** Copyright (c) 2015-2024 MinIO, Inc.
- **Source:** https://github.com/minio/minio
- **License Text:** https://github.com/minio/minio/blob/master/LICENSE

---

## HashiCorp Vault

- **Component:** HashiCorp Vault - Secrets management
- **Image:** `hashicorp/vault:1.19.0`
- **License:** Business Source License 1.1 (BUSL 1.1)
- **Copyright:** Copyright (c) 2024 IBM Corp.
- **Source:** https://github.com/hashicorp/vault
- **License Text:** https://github.com/hashicorp/vault/blob/main/LICENSE

---

## Postfix

- **Component:** Postfix Mail Transfer Agent
- **Image:** `boky/postfix:latest` (based on official Postfix)
- **License:** Postfix License (IPLR - Independent Postfix License)
- **Copyright:** Copyright (c) 1991-2024, Internet Systems Consortium, Inc.
- **Source:** https://www.postfix.org/
- **License Text:** https://www.postfix.org/LICENSE.html

---

## Alpine Linux

- **Component:** Alpine Linux - Minimal Linux distribution (used as base for version-collector)
- **Image:** `alpine:latest`
- **License:** GPL v2+ (system components); individual packages have their own licenses
- **Copyright:** Copyright (c) 2012-2024 Alpine Linux Project
- **Source:** https://alpinelinux.org/
- **License Text:** https://gitlab.alpinelinux.org/alpine/aports/-/blob/master/main/alpine-baselayout/LICENSE

---

## Docker

- **Component:** Docker Engine & Docker Compose (runtime)
- **License:** Apache License 2.0 (Moby project); Docker Engine uses various licenses
- **Source:** https://www.docker.com/
- **Note:** Docker is a runtime dependency, not distributed with this project.

---

## Summary

| Component | License | Type |
|---|---|---|
| Dozzle | MIT | Permissive |
| PostgreSQL | PostgreSQL License | Permissive |
| Node Exporter | Apache 2.0 | Permissive |
| Promtail | AGPL v3 | Copyleft |
| MinIO | AGPL v3 | Copyleft |
| HashiCorp Vault | BUSL 1.1 | Source-available |
| Postfix | IPLR | Permissive |
| Alpine Linux | GPL v2+ | Copyleft (base OS) |

All components are used as unmodified Docker containers. No source code from these projects has been modified or incorporated into this repository.
