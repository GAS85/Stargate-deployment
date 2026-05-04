# Stargate Deployment Instruction

!!! warning "ACTIVE DEVELOPMENT - NOT A FINAL PRODUCT"

    Stargate (HIN MGW) is under active development.

    Interfaces, configuration, and behaviour may change between releases.

    A web-based admin UI dashboard is currently under development. Until it is released, all configuration and operations are performed over the terminal using the scripts in this repository.

![Logo](https://www.hin.ch/files/png1/hero/stargate_visual.png)

[What is Stargate?](https://www.hin.ch/de/services/hin-mail/hin-gateway.cfm){ .md-button style="position:relative;left:50%;transform:translate(-50%,0%);" }

## Quick Start

### Installation options

* Container installation:
    * [Docker installation](./Docker-deploy.md)
    * [HELM charts](./helm-deploy.md)
* VM image installation:
    * [Azure VM image installation](vm/Azure-image-install.md)
    * [Windows 11 pro (Hyper-V) image installation](vm/Windows11pro-image-install.md)
    * [VMware image installation](vm/VMware-image-install.md)
    * [Proxmox image installation](vm/Proxmox-image-install.md)

!!! tip "🖨️"
    You can get this documentation printed or saved as pdf, please visit our [Print page view](print_page).

### Exchange Integration

* [Exchange integration](Exchange-integration.md) - Configure Microsoft Exchange (Online and On-Premises) connectors and transport rules to route mail through Stargate

### Server Requirements

#### Minimum

* **2** CPU cores
* **4 GB** RAM
* **20 GB** storage

#### Recomended

* **4** CPU cores
* **8 GB** RAM
* **30 GB** storage

#### Common Requirements

* **Root access**: Must be run as root or with `sudo`
* Supported distributions:
    * RHEL 8, 9 and 10 compatible distributions such as Alma Linux, Rocky Linux, Centos Stream
    * Ubuntu 22 and 24
    * Debian 11, 12 and 13
* **Real IPv4 address**
* **Valid DNS records**. Your domain must have:
    * MX records pointing to your mail servers
    * SPF record defining allowed sending networks
    * Server must be able to resolve DNS (MX, SPF, A records)
    * Used for mail routing and SPF-based network allowlisting

#### Inbound Network Access (firewall must allow)

| Port | Protocol | Purpose |
|------|----------|---------|
| 25 | TCP | SMTP - receiving mail from external servers |
| 8084 | TCP | HTTP - seal callback from remote sealer service |
| 19818 | TCP+UDP | WireGuard - encrypted tunnel for agent-to-agent communication |

#### Outbound Network Access (server must reach)

| Destination | Port | Purpose |
|-------------|------|---------|
| registry.vereign.io | 443 | Docker image registry |
| mxengine-dev.k8s.vereign-cdn.com | 443 | Remote sealer service |
| smimekeys-ca-dev.k8s.vereign-cdn.com | 443 | S/MIME CA service |
| loki.infra.vereign-cdn.com | 443 | Log shipping (Promtail → Loki) |
| vereign-issuer.vrgnservices.eu | 443 | Issuer service |
| vereign-verifier.vrgnservices.eu | 4433 | Verifier service |
| Destination mail servers | 25 | Outbound mail delivery (via MX lookup) |

## Contact us

[Contact us](https://www.hin.ch/de/kontakt/kontaktformular.cfm){ .md-button style="position:relative;left:50%;transform:translate(-50%,0%);" }
