#!/bin/bash
# Wrapper script for boky/postfix that auto-configures from DNS
# Integrates with mxengine for mail processing

set -e

# Required configuration
MAIL_DOMAIN="${MAIL_DOMAIN:-}"
MAIL_HOSTNAME="${MAIL_HOSTNAME:-mail.${MAIL_DOMAIN}}"
DNS_TIMEOUT="${DNS_TIMEOUT:-2}"
DNS_SERVER="${DNS_SERVER:-}"
ENABLE_IPV6="${ENABLE_IPV6:-false}"

# MXEngine integration (Docker service name)
MXENGINE_HOST="${MXENGINE_HOST:-mxengine}"
MXENGINE_PORT="${MXENGINE_PORT:-1587}"

# Optional manual overrides (skip DNS lookup if set)
MANUAL_RELAYHOST="${RELAYHOST:-}"
MANUAL_MYNETWORKS="${MYNETWORKS:-}"

if [ -z "$MAIL_DOMAIN" ]; then
    echo "ERROR: MAIL_DOMAIN environment variable is required"
    exit 1
fi

echo "=== Postfix Relay Auto-Configuration ==="
echo "Domain: $MAIL_DOMAIN"
echo "Hostname: $MAIL_HOSTNAME"

##############################################################################
# SPF Tools - Extract IP addresses from SPF records
##############################################################################

myhost() { 
    if [ -n "$DNS_SERVER" ]; then
        host -W "$DNS_TIMEOUT" "$@" "$DNS_SERVER"
    else
        host -W "$DNS_TIMEOUT" "$@"
    fi
}

get_txt() { 
    myhost -t TXT "$1" 2>/dev/null | grep -i 'descriptive text' | cut -d\" -f2- | sed -e 's/" "//g;s/"$//' 
}

get_mx() { 
    myhost -t MX "$1" 2>/dev/null | awk '/mail is handled/ {print $NF}' 
}

get_addr() { 
    myhost -t "$1" "$2" 2>/dev/null | awk '/address/ {print $NF}' 
}

checkval4() {
    local ip=$1
    local cidr=${2#/}
    
    if [ -n "$cidr" ]; then
        [ "$cidr" -le 32 ] 2>/dev/null || return 1
    fi
    
    local D=$(echo "$ip" | grep -Eo '\.' | wc -l)
    [ "$D" -eq 3 ] || return 1
    
    for i in $(echo "$ip" | tr '.' ' '); do
        [ "$i" -le 255 ] 2>/dev/null || return 1
    done
    return 0
}

checkval6() {
    local ip=$1
    local cidr=${2#/}
    
    if [ -n "$cidr" ]; then
        [ "$cidr" -le 128 ] 2>/dev/null || return 1
    fi
    
    # Basic IPv6 validation
    echo "$ip" | grep -qE '^[0-9a-fA-F:]+$' || return 1
    return 0
}

printip() {
    while read -r line; do
        [ -z "$line" ] && continue
        
        local prefix=""
        if echo "$line" | grep -q '/'; then
            prefix="/${line##*/}"
            line=$(echo "$line" | cut -d/ -f1)
        fi
        
        if echo "$line" | grep -q ':'; then
            checkval6 "$line" "$prefix" && echo "${line}${prefix}"
        elif echo "$line" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'; then
            checkval4 "$line" "$prefix" && echo "${line}${prefix}"
        fi
    done
}

# Get A/AAAA records for a hostname
dea() {
    local hostname=$1
    local cidr=$2
    
    for TYPE in A AAAA; do
        get_addr "$TYPE" "$hostname" | while read -r ip; do
            [ -n "$ip" ] && echo "$ip" | printip
        done
    done
}

# Get MX records and resolve to IPs
demx() {
    local domain=$1
    local cidr=$2
    
    local mxhosts=$(get_mx "$domain")
    for mx in $mxhosts; do
        mx=$(echo "$mx" | sed 's/\.$//')
        dea "$mx" "$cidr"
    done
}

# Parse SPF record
parsepf() {
    local domain=$1
    get_txt "$domain" | grep -Eio 'v=spf1[^"]*' | head -1
}

# Recursive SPF resolver
despf() {
    local domain=$1
    local visited=$2
    
    # Detect loops
    if grep -qxF "$domain" "$visited" 2>/dev/null; then
        return
    fi
    echo "$domain" >> "$visited"
    
    local spf=$(parsepf "$domain")
    [ -z "$spf" ] && return
    
    # Process includes
    echo "$spf" | grep -Eio 'include:[^ ]+' | while read -r inc; do
        local included=$(echo "$inc" | cut -d: -f2)
        if ! echo "$included" | grep -q '%{'; then
            echo "  Processing include: $included" >&2
            despf "$included" "$visited"
        fi
    done
    
    # Process redirects
    echo "$spf" | grep -Eio 'redirect=[^ ]+' | while read -r redir; do
        local target=$(echo "$redir" | cut -d= -f2)
        echo "  Processing redirect: $target" >&2
        despf "$target" "$visited"
    done
    
    # Extract IP4
    echo "$spf" | grep -Eio 'ip4:[^ ]+' | sed 's/ip4://' | printip
    
    # Extract IP6 - format as [ipv6]/cidr for Postfix mynetworks
    echo "$spf" | grep -Eio 'ip6:[^ ]+' | sed 's/ip6://' | while read -r ip6; do
        if echo "$ip6" | grep -q '/'; then
            # Has CIDR - format as [address]/cidr
            local addr="${ip6%/*}"
            local cidr="${ip6##*/}"
            echo "[${addr}]/${cidr}"
        else
            # No CIDR - just bracket the address
            echo "[${ip6}]"
        fi
    done
    
    # Process a: mechanism
    echo "$spf" | grep -Eio '\ba:[^ ]*' | while read -r amech; do
        local ahost=$(echo "$amech" | cut -d: -f2-)
        [ -z "$ahost" ] && ahost="$domain"
        dea "$ahost" ""
    done
    
    # Process mx mechanism
    echo "$spf" | grep -Eio '\bmx[: ]' | while read -r _; do
        demx "$domain" ""
    done
}

get_spf_networks() {
    local domain=$1
    local loopfile=$(mktemp)
    
    echo "Parsing SPF records for $domain..." >&2
    despf "$domain" "$loopfile" | sort -u | tr '\n' ' '
    
    rm -f "$loopfile"
}

get_mx_relay() {
    local domain=$1
    local hostname=$2
    
    echo "Retrieving MX records for $domain..." >&2
    local mxhosts=$(get_mx "$domain" | grep -v "$hostname" | sed 's/\.$//' | head -5)
    
    if [ -z "$mxhosts" ]; then
        echo "ERROR: No MX records found for $domain" >&2
        return 1
    fi
    
    # Format for Postfix: [host1],[host2]
    echo "$mxhosts" | sed 's/^/[/;s/$/]/' | tr '\n' ',' | sed 's/,$//'
}

##############################################################################
# Main Configuration
##############################################################################

# Get relay host from MX or use manual override
if [ -n "$MANUAL_RELAYHOST" ]; then
    echo "Using manual RELAYHOST: $MANUAL_RELAYHOST"
    RELAY_DEST="$MANUAL_RELAYHOST"
else
    RELAY_DEST=$(get_mx_relay "$MAIL_DOMAIN" "$MAIL_HOSTNAME")
    if [ -z "$RELAY_DEST" ]; then
        echo "ERROR: Could not determine relay host from MX records"
        exit 1
    fi
    echo "Relay destination from MX: $RELAY_DEST"
fi

# Get allowed networks from SPF or use manual override
if [ -n "$MANUAL_MYNETWORKS" ]; then
    echo "Using manual MYNETWORKS: $MANUAL_MYNETWORKS"
    export MYNETWORKS="$MANUAL_MYNETWORKS"
else
    SPF_NETWORKS=$(get_spf_networks "$MAIL_DOMAIN")
    if [ -z "$SPF_NETWORKS" ]; then
        echo "WARNING: No SPF records found, using Docker networks only"
        SPF_NETWORKS=""
    fi
    # Always include localhost and common Docker network ranges
    # Docker compose creates networks in 172.16.0.0/12 range
    DOCKER_RANGES="10.0.0.0/8 172.16.0.0/12 192.168.0.0/16"
    export MYNETWORKS="127.0.0.0/8 $DOCKER_RANGES $SPF_NETWORKS"
    echo "Networks (Docker + SPF): $MYNETWORKS"
fi

# Set allowed sender domains
export ALLOWED_SENDER_DOMAINS="$MAIL_DOMAIN"

# Set hostname
export HOSTNAME="$MAIL_HOSTNAME"

# Disable relayhost - we use transport maps instead
export RELAYHOST=""

# Set IPv6
if [ "$ENABLE_IPV6" = "true" ]; then
    export POSTFIX_inet_protocols="all"
else
    export POSTFIX_inet_protocols="ipv4"
fi

echo ""
echo "=== Configuration Summary ==="
echo "  MAIL_DOMAIN: $MAIL_DOMAIN"
echo "  HOSTNAME: $HOSTNAME"
echo "  RELAY_DEST: $RELAY_DEST"
echo "  MXENGINE: $MXENGINE_HOST:$MXENGINE_PORT"
echo "  MYNETWORKS: $MYNETWORKS"
echo "  ALLOWED_SENDER_DOMAINS: $ALLOWED_SENDER_DOMAINS"
echo ""

##############################################################################
# Post-startup configuration (runs after boky/postfix starts)
##############################################################################

# Auto-detect Docker networks from container's interfaces
get_docker_networks() {
    local networks=""
    
    # Get networks from ip route (most reliable)
    if command -v ip >/dev/null 2>&1; then
        networks=$(ip route | awk '/^[0-9]/ && !/default/ {print $1}' | grep -E '^(10\.|172\.|192\.168\.)' | tr '\n' ',' | sed 's/,$//')
    fi
    
    # Fallback: try to get from interface addresses
    if [ -z "$networks" ] && command -v hostname >/dev/null 2>&1; then
        local my_ip=$(hostname -i 2>/dev/null | awk '{print $1}')
        if [ -n "$my_ip" ]; then
            # Derive /16 network from IP
            local net_prefix=$(echo "$my_ip" | cut -d. -f1-2)
            networks="${net_prefix}.0.0/16"
        fi
    fi
    
    # Ultimate fallback: standard Docker ranges
    if [ -z "$networks" ]; then
        networks="172.16.0.0/12,10.0.0.0/8,192.168.0.0/16"
    fi
    
    echo "$networks"
}

configure_postfix() {
    echo "=== Applying MXEngine Integration ==="
    
    # Wait for postfix to be ready
    sleep 2
    
    # Auto-detect Docker networks for mynetworks on port 10026
    local docker_nets=$(get_docker_networks)
    echo "Detected Docker networks: $docker_nets"
    
    # Add port 10026 listener for mail returning from mxengine
    # This port has no content_filter to avoid loops
    if ! grep -q "^0.0.0.0:10026" /etc/postfix/master.cf 2>/dev/null; then
        echo "Adding port 10026 listener for mxengine return path..."
        echo "0.0.0.0:10026 inet n - n - 10 smtpd -o content_filter= -o receive_override_options=no_unknown_recipient_checks,no_header_body_checks,no_milters -o smtpd_authorized_xforward_hosts=${docker_nets} -o smtpd_tls_security_level=none -o mynetworks=${docker_nets}" >> /etc/postfix/master.cf
    fi
    
    # Configure content_filter to send mail to mxengine
    if ! grep -q "^content_filter" /etc/postfix/main.cf 2>/dev/null; then
        echo "Setting content_filter to mxengine..."
        echo "content_filter = smtp:[$MXENGINE_HOST]:$MXENGINE_PORT" >> /etc/postfix/main.cf
    fi
    
    # Add receive_override_options
    if ! grep -q "^receive_override_options" /etc/postfix/main.cf 2>/dev/null; then
        echo "receive_override_options = no_address_mappings" >> /etc/postfix/main.cf
    fi
    
    # Create transport map for outbound relay
    echo "Creating transport map..."
    echo "$MAIL_DOMAIN relay:$RELAY_DEST" > /etc/postfix/transport
    postmap lmdb:/etc/postfix/transport
    
    # Add transport_maps if not present
    if ! grep -q "^transport_maps" /etc/postfix/main.cf 2>/dev/null; then
        echo "transport_maps = lmdb:/etc/postfix/transport" >> /etc/postfix/main.cf
    fi
    
    # Set relay_domains
    sed -i '/^relay_domains/d' /etc/postfix/main.cf
    echo "relay_domains = $MAIL_DOMAIN" >> /etc/postfix/main.cf
    
    # Disable relayhost (we use transport maps)
    sed -i 's/^relayhost/#relayhost/' /etc/postfix/main.cf
    
    # Set myhostname
    sed -i '/^myhostname/d' /etc/postfix/main.cf
    echo "myhostname = $MAIL_HOSTNAME" >> /etc/postfix/main.cf
    
    # Disable restrictive settings that may interfere
    sed -i 's/^smtpd_relay_restrictions/#smtpd_relay_restrictions/' /etc/postfix/main.cf
    sed -i 's/^smtpd_client_restrictions/#smtpd_client_restrictions/' /etc/postfix/main.cf
    sed -i 's/^smtpd_helo_restrictions/#smtpd_helo_restrictions/' /etc/postfix/main.cf
    sed -i 's/^smtpd_sender_restrictions/#smtpd_sender_restrictions/' /etc/postfix/main.cf
    sed -i 's/^smtpd_recipient_restrictions/#smtpd_recipient_restrictions/' /etc/postfix/main.cf
    
    echo "=== Reloading Postfix ==="
    postfix reload || true
    
    echo "=== MXEngine Integration Complete ==="
}

wait_for_postfix() {
    echo "Waiting for Postfix to be ready..."
    local max_wait=60
    local waited=0
    
    # Wait for postfix process AND config to be ready
    while [ $waited -lt $max_wait ]; do
        if postfix status >/dev/null 2>&1 && grep -q "^myhostname" /etc/postfix/main.cf 2>/dev/null; then
            # Brief pause to ensure config file is fully flushed
            sleep 1
            echo "Postfix is ready (waited ${waited}s)"
            return 0
        fi
        sleep 1
        waited=$((waited + 1))
    done
    
    # Provide specific error message
    if ! postfix status >/dev/null 2>&1; then
        echo "ERROR: Timed out waiting for Postfix process"
    else
        echo "ERROR: Timed out waiting for Postfix configuration"
    fi
    return 1
}

# Run configuration in background after postfix fully starts
(wait_for_postfix && configure_postfix) &

# Execute the original boky/postfix entrypoint
exec /scripts/run.sh "$@"
