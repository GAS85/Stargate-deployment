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

# Primary mail domain for the Postfix relay
# This domain's MX records determine where to relay mail
# SPF records determine which networks are allowed to send
# Example: "example.com", "customer.eu"
MAIL_DOMAIN=""

# Mail server hostname (optional, defaults to mail.<MAIL_DOMAIN>)
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
# OPTIONAL: Advanced Mail Configuration
# ==============================================================================
# These are typically auto-configured from DNS. Only set if you need overrides.

# Enable IPv6 for Postfix (default: false)
# Note: Microsoft Exchange connector GUI doesn't support IPv6
POSTFIX_ENABLE_IPV6=""

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
# END OF CONFIGURATION
# ==============================================================================
