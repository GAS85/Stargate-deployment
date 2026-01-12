#!/bin/bash
# Wrapper script for boky/postfix that auto-configures from DNS
# Based on relaysetup.sh SPF/MX parsing logic

set -e

# Required configuration
MAIL_DOMAIN="${MAIL_DOMAIN:-}"
MAIL_HOSTNAME="${MAIL_HOSTNAME:-$(hostname)}"
DNS_TIMEOUT="${DNS_TIMEOUT:-2}"
DNS_SERVER="${DNS_SERVER:-}"
ENABLE_IPV6="${ENABLE_IPV6:-false}"

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
    
    # Extract IP6
    echo "$spf" | grep -Eio 'ip6:[^ ]+' | sed 's/ip6://' | while read -r ip6; do
        echo "[$ip6]"
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
    export RELAYHOST="$MANUAL_RELAYHOST"
else
    RELAYHOST=$(get_mx_relay "$MAIL_DOMAIN" "$MAIL_HOSTNAME")
    if [ -z "$RELAYHOST" ]; then
        echo "ERROR: Could not determine relay host from MX records"
        exit 1
    fi
    echo "Relay host from MX: $RELAYHOST"
    export RELAYHOST
fi

# Get allowed networks from SPF or use manual override
if [ -n "$MANUAL_MYNETWORKS" ]; then
    echo "Using manual MYNETWORKS: $MANUAL_MYNETWORKS"
    export MYNETWORKS="$MANUAL_MYNETWORKS"
else
    SPF_NETWORKS=$(get_spf_networks "$MAIL_DOMAIN")
    if [ -z "$SPF_NETWORKS" ]; then
        echo "WARNING: No SPF records found, using Docker networks only"
        SPF_NETWORKS="10.0.0.0/8 172.16.0.0/12 192.168.0.0/16"
    fi
    # Add localhost and Docker networks
    export MYNETWORKS="127.0.0.0/8 $SPF_NETWORKS"
    echo "Networks from SPF: $MYNETWORKS"
fi

# Set allowed sender domains
export ALLOWED_SENDER_DOMAINS="$MAIL_DOMAIN"

# Set hostname
export HOSTNAME="$MAIL_HOSTNAME"

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
echo "  RELAYHOST: $RELAYHOST"
echo "  MYNETWORKS: $MYNETWORKS"
echo "  ALLOWED_SENDER_DOMAINS: $ALLOWED_SENDER_DOMAINS"
echo ""

# Execute the original boky/postfix entrypoint
exec /run.sh "$@"
