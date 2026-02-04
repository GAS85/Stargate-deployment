# Postfix Relay Setup

Automated (script)[https://code.vereign.com/svdh/stargate-deployment/-/blob/main/docker-compose/scripts/relaysetup.sh] to install and configure Postfix as a mail relay server using DNS records for configuration.

## Overview

This script automatically:
- Detects your Linux distribution
- Installs Postfix and required DNS utilities
- Retrieves MX records for your mail domain
- Parses SPF records to determine allowed relay networks
- Configures Postfix as a relay to your domain's mail servers
- Sets up network restrictions based on SPF records

## Prerequisites

- **Root access**: Must be run as root or with `sudo`
- **Supported distributions**: 
  - Ubuntu 22 and newer
  - Debian 12 and newer
  - RHEL-based (CentOS, Rocky Linux, AlmaLinux) version 9 and newer
- **Real IPv4 address** 
- **Valid DNS records**: Your domain must have:
  - MX records pointing to your mail servers
  - SPF record defining allowed sending networks

## Installation & Usage

### Basic Usage

The script will auto-detect the mail domain from your hostname:

```bash
sudo ./relaysetup.sh
```

### Specify Domain Explicitly

If you want to configure a specific domain:

```bash
sudo maildomain=example.com ./relaysetup.sh
```

### Specify Hostname Explicitly

If you want to configure a specific hostname:

```bash
sudo mailhostname=mail.example.com ./relaysetup.sh
```

## What the Script Does

- **Detects domain** - Uses `hostname -d` or environment variable
- **Detects Linux distribution** - Reads `/etc/os-release`
- **Installs packages**:
   - Debian/Ubuntu: `postfix`, `bind9-host`, `postfix-lmdb`, `ssl-cert`, `dnsutils`
   - RHEL-based: `postfix`, `bind-utils`, `postfix-lmdb`
- **Retrieves MX records** - Finds mail servers for your domain
- **Parses SPF records** - Extracts allowed IP networks recursively
- **Creates transport map** - Routes mail for your domain to the MX servers
- **Configures Postfix** - Updates `/etc/postfix/main.cf` with:
   - LMDB transport maps
   - Relay for your domain
   - Restrict relay access to SPF-defined networks
- **Enables and starts Postfix** - Ensures service runs on boot

## Configuration

### Environment Variables

- `maildomain` - The mail domain to configure (default: auto-detected from hostname)
- `mailhostname` - The mail hostname to configure (default: auto-detected from hostname)
- `dns_timeout` - DNS query timeout in seconds (default: 2)
- `dns_server` - Specific DNS server to use (default: uses `/etc/resolv.conf`)
- `ipv6` - If ipv6=true , postfix will serve on both ipv4 and ipv6 (default: false, use only ipv4). The MS Exchange connectors(transport maps) GUI, does not allow ipv6 addresses, so all mail from ipv6 will be rejected.

### Example with Custom DNS Server

```bash
sudo dns_server=8.8.8.8 maildomain=example.com ./relaysetup.sh
```

## Example Output

```
Configuring Postfix relay for domain: example.com
Installing required packages...
Getting SPF and MX settings from DNS for example.com...
Retrieving MX records...
Parsing SPF records...
Getting spf.protection.outlook.com
Setting up Postfix configuration...
Enabling and starting Postfix...
SUCCESS: Postfix relay has been configured and is running
Configuration summary:
  Domain: example.com
  Relay destination: [smtp.example.com]
  Allowed networks: 192.0.2.0/24 198.51.100.0/24 [2001:db8::/32]
```

## Files Modified

The script modifies the following files:

- `/etc/postfix/main.cf` - Main Postfix configuration
- `/etc/postfix/transport` - Transport map for relay routing
- `/etc/postfix/transport.lmdb` - Compiled transport map

## Verification

After running the script, verify the configuration:

```bash
# Check Postfix status
sudo systemctl status postfix

# View Postfix configuration
sudo postconf | grep -E 'inet_interfaces|inet_protocols|transport_maps|relay_domains|mynetworks'

# View transport map
sudo postmap -q example.com lmdb:/etc/postfix/transport

# Test mail relay (replace with your domain)
echo "Test" | mail -s "Test from relay" user@example.com

# Check Postfix logs
sudo tail -f /var/log/mail.log
sudo journalctl -u postfix -f
```

## Troubleshooting

### DNS Lookup Failures

**Problem**: Script fails with "Failed to retrieve SPF records"

**Solutions**:
- Verify your domain has SPF records: `host -t TXT example.com`
- Check DNS connectivity: `host -t MX example.com`
- Try using a different DNS server: `sudo dns_server=8.8.8.8 ./relaysetup.sh`

### No MX Records Found

**Problem**: "ERROR: No MX records found for domain"

**Solutions**:
- Verify MX records exist: `host -t MX example.com`
- Ensure your domain is correctly set
- Check that your DNS server is responding

### Postfix Won't Start

**Problem**: "ERROR: Postfix failed to start"

**Solutions**:
- Check logs: `sudo journalctl -xeu postfix`
- Verify configuration: `sudo postfix check`
- Check for port conflicts: `sudo ss -tlnp | grep :25`

### Mail Not Being Relayed

**Problem**: Mail is rejected or not relayed

**Solutions**:
- Verify sending IP is in allowed networks: `sudo postconf mynetworks`
- Check transport map: `sudo postmap -q yourdomain.com lmdb:/etc/postfix/transport`
- Review Postfix logs for rejection reasons
- Ensure firewall allows outbound SMTP (port 25)

## Security Considerations

- The script configures Postfix to relay **only** for the specified domain
- Only IP addresses/networks listed in SPF records will be accepted for relay
