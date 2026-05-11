# Stargate Deployment Instruction

!!! warning "ACTIVE DEVELOPMENT - NOT A FINAL PRODUCT"

    Stargate (HIN MGW) is under active development.

    Interfaces, configuration, and behaviour may change between releases.

    A web-based admin UI dashboard is in the works - until it ships, all configuration and operations are performed over the terminal using the scripts in this repository.

![Logo](https://www.hin.ch/files/png1/hero/stargate_visual.png)

## Quick Start

### Installation options

* [Docker installation](./Docker-deploy.md)
* [HELM charts](./helm-deploy.md)
* VM image installation
    * [Azure VM image installation](vm/Azure-image-install.md)
    * [Windows 11 pro (Hyper-V) image installation](vm/Windows11pro-image-install.md)
    * [VMware image installation](vm/VMware-image-install.md)
    * [Proxmox image installation](vm/Proxmox-image-install.md)

### Exchange Integration

* [Exchange-integration.md](Exchange-integration.md) - Configure Microsoft Exchange (Online and On-Premises) connectors and transport rules to route mail through Stargate

### Prerequisites

**Server Requirements:**

* 4 CPU cores (recommended minimum)
* 8 GB RAM (recommended minimum)
* 30 GB storage (recommended minimum)
* Docker will be installed automatically if missing
* Ensure there is an internet connection on the machine where you are installing Stargate services
* Ensure traffic is properly configured to reach Stargate instance

**Supported Linux Distributions:**

* RHEL 8, 9 and 10 compatible distributions such as Alma Linux, Rocky Linux, Centos Stream
* Ubuntu 22 and 24
* Debian 11, 12 and 13

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

* Server must be able to resolve DNS (MX, SPF, A records)
* Used for mail routing and SPF-based network allowlisting
* See the [DNS Setup Guide](DNS-setup.md) for all required DNS records
