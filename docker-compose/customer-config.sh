#!/bin/bash
# ==============================================================================
# Stargate Customer Configuration
# ==============================================================================
# This file contains all customer-specific settings for the Stargate deployment.
# Fill in the required fields and optionally customize the others.
# 
# After filling this file, run: ./scripts/install.sh
# ==============================================================================

# ==============================================================================
# REQUIRED: Customer Identification
# ==============================================================================

# Customer/Organization name (used for identification and logging)
CUSTOMER_NAME=""

# Deployment name (used for log labels and identification)
# Example: "stargate-production", "customer-alpha"
DEPLOYMENT_NAME=""

# ==============================================================================
# REQUIRED: Mail Configuration
# ==============================================================================

# Mail domains for the Postfix relay (comma-separated for multiple domains)
# MX records for each domain determine where to relay mail
# SPF records for each domain determine which networks are allowed to send
# Example: "example.com" or "example.com,otherdomain.com"
MAIL_DOMAINS=""

# Mail server hostname (optional, defaults to mail.<first domain>)
# This is announced in SMTP HELO/EHLO
# Example: "mail.example.com"
MAIL_HOSTNAME=""

# MXEngine public address (REQUIRED for seal strategy callbacks)
# This must be the publicly accessible URL where the sealer can reach mxengine
# Example: "http://203.0.113.10:8084" or "https://mxengine.example.com"
MXENGINE_PUBLIC_ADDRESS=""

# ==============================================================================
# REQUIRED: S/MIME Certificate Configuration
# ==============================================================================
# These values are used when generating the S/MIME signing key and CSR
# during installation.

# DNS names for the certificate (comma-separated)
# These should be the domains this instance will sign emails for
# Example: "example.com,mail.example.com"
CERT_DNS_NAMES=""

# Organization name for the certificate subject
# Example: "Acme Corporation"
CERT_ORGANIZATION=""

# Common Name for the certificate subject
# Usually same as organization or a descriptive name
# Example: "Acme Corporation Mail Signing"
CERT_COMMON_NAME=""

# Countries for the certificate subject (comma-separated, 2-letter codes)
# Example: "US,DE" or "CH"
CERT_COUNTRIES=""

# CA IDAgent domain for certificate issuance via WireGuard tunnel
# This is the domain used to reach the CA through the idagent tunnel
# Contact Vereign for the correct value
CERT_CA_IDAGENT_DOMAIN=""

# ==============================================================================
# OPTIONAL: Database Configuration
# ==============================================================================
# Leave empty to use defaults. Passwords will be auto-generated if empty.

# PostgreSQL username (default: postgres)
POSTGRES_USER=""

# PostgreSQL password (default: auto-generated secure password)
# If left empty, a random password will be generated during install
POSTGRES_PASSWORD=""

# ==============================================================================
# OPTIONAL: Object Storage Configuration
# ==============================================================================
# Leave empty to use defaults. Passwords will be auto-generated if empty.

# MinIO root username (default: minioadmin)
MINIO_ROOT_USER=""

# MinIO root password (default: auto-generated secure password)
# If left empty, a random password will be generated during install
MINIO_ROOT_PASSWORD=""

# S3 bucket name for storing messages and attachments (default: stargate-bucket)
S3_BUCKET_NAME=""

# ==============================================================================
# OPTIONAL: Application Versions
# ==============================================================================
# Specify version tags for the application images.
# Use "latest" for most recent stable, "dev" for development builds,
# or specific version tags like "v1.2.3"

# S/MIME Keys service version (default: latest)
SMIMEKEYS_VERSION=""

# Policy service version (default: latest)
POLICY_VERSION=""

# ID Agent service version (default: latest)
IDAGENT_VERSION=""

# MX Engine service version (default: latest)
MXENGINE_VERSION=""

# ==============================================================================
# OPTIONAL: Policy Sync Configuration
# ==============================================================================
# policy-sync syncs OPA/Rego policies from a Git repository to the database.
# If POLICY_SYNC_REPO_URL is set, the service will be enabled.
# Leave empty to disable policy-sync (policies must be managed manually).

# Git repository URL containing policies (required to enable policy-sync)
# Example: "git@github.com:Health-Info-Net-AG/Stargate-policies.git"
POLICY_SYNC_REPO_URL=""

# Git username for private repositories (optional)
POLICY_SYNC_REPO_USER=""

# Git password/token for private repositories (optional)
POLICY_SYNC_REPO_PASS=""

# Git branch to checkout (optional, defaults to repo's default branch)
POLICY_SYNC_REPO_BRANCH=""

# Subfolder within repo to scan for policies (optional)
# Policies must follow structure: {folder}/{group}/{name}/policy.rego
POLICY_SYNC_REPO_FOLDER=""

# Sync interval (optional, default: 1h, minimum: 1m)
# Examples: "5m", "1h", "30m"
POLICY_SYNC_INTERVAL=""

# Policy sync service version (default: dev)
POLICY_SYNC_VERSION=""

# ==============================================================================
# OPTIONAL: Advanced Mail Configuration
# ==============================================================================
# These are typically auto-configured from DNS. Only set if you need overrides.

# Sealer MX domain for outbound seal delivery (REQUIRED)
# This is the domain used by the sealer service for MX-based delivery
OUTBOUND_SEALER_MX_DOMAIN=""

# External SMTP host for outbound delivery (default: postfix-relay)
# Set this if the customer uses an external Postfix server
OUTBOUND_SMTP_HOST=""

# External SMTP port for outbound delivery (default: 10026)
OUTBOUND_SMTP_PORT=""

# Enable IPv6 for Postfix (default: false)
# Note: Microsoft Exchange connector GUI doesn't support IPv6
POSTFIX_ENABLE_IPV6="false"

# Manual relay host override (skips MX lookup)
# Format: [hostname] or [hostname]:port
# Example: "[smtp.example.com]:587"
RELAYHOST=""

# Manual allowed networks override (skips SPF lookup)
# Space-separated CIDR ranges
# Example: "10.0.0.0/8 192.168.0.0/16"
POSTFIX_MYNETWORKS=""

# DNS server to use for lookups (default: system resolver)
DNS_SERVER=""

# DNS lookup timeout in seconds (default: 2)
DNS_TIMEOUT=""

# ==============================================================================
# OPTIONAL: Monitoring Configuration
# ==============================================================================

# Loki URL for centralized logging (default: Vereign's Loki instance)
# Only change if using your own Loki instance
LOKI_URL=""

# ==============================================================================
# REQUIRED: WireGuard Configuration
# ==============================================================================
# Local WireGuard settings for this IDAgent instance.

# WireGuard private key (optional - auto-generated if empty, then saved back here)
# After first install, this will be populated automatically so the key persists
# across VM recreations. KEEP THIS FILE BACKED UP!
WG_PRIVATE_KEY=""

# Local WireGuard IP address for this instance.
# Use this server's real static public IP address as the WireGuard internal IP.
# This guarantees uniqueness across all deployments (no coordination needed).
WG_LOCAL_IP=""

# WireGuard interface port (default: 19818)
WG_INTERFACE_PORT=""

# WireGuard transport mode: "tcp" (default) or "udp"
# Set to "udp" only if TCP tunneling causes issues
WG_TRANSPORT_MODE=""

# ==============================================================================
# REQUIRED: WireGuard Peer Configuration
# ==============================================================================
# Configuration for WireGuard tunnel connection to remote IDAgent instance.
# This enables secure agent-to-agent communication for sealed message delivery.

# Unique connection identifier (auto-generated UUID v7 if left empty)
WG_PEER_CONNECTION_ID=""

# Human-readable name for this connection
WG_PEER_NAME=""

# WireGuard public key of the REMOTE peer (REQUIRED)
WG_PEER_PUBLIC_KEY="WhTN0ekf/jT+wAv9kIIHmwMLPWr9Gv1MXxnvAkJKbHU="

# Remote peer endpoint (host:port) (REQUIRED)
WG_PEER_ENDPOINT=""

# WireGuard IP address of the remote peer
WG_PEER_IP=""

# Port to use for communication with the remote peer
WG_PEER_PORT=""

# Allowed IPs for routing (defaults to WG_PEER_IP/32)
WG_PEER_ALLOWED_IPS=""

# External identifier for the remote organization/domain
WG_PEER_EXTERNAL_ID=""

# Description of this connection
WG_PEER_DESCRIPTION=""

# ==============================================================================
# END OF CONFIGURATION
# ==============================================================================
