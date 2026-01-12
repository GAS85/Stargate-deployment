#!/bin/bash
# Copyright 2025 Vereign AG - see License for more details
# https://code.vereign.com/svdh/postfix-relay/-/raw/master/LICENSE
# The spftoolsdespf function is based on the despf tool from https://github.com/spf-tools/spf-tools

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
  echo "ERROR: This script must be run as root or with sudo"
  exit 1
fi

# Set hostname from environment variable or hostname
if [ -z "$mailhostname" ]; then
    mailhostname=$(hostname)
fi

# Set mail domain from environment variable or mailhostname
if [ -z "$maildomain" ]; then 
    maildomain=$(echo $mailhostname|rev|cut -f1,2 -d.|rev)
    if [ -z "$maildomain" ]; then
        echo "ERROR: Cannot determine mail domain. Please set it explicitly:"
        echo "  sudo maildomain=example.com $0"
        exit 1
    fi
fi

echo "Configuring Postfix relay on $mailhostname for domain: $maildomain"

# Detect Linux distribution
if [ -f /etc/os-release ]; then
    dist_id=$(grep ^ID= /etc/os-release | cut -f2 -d= | sed 's/"//g')
else
    echo "ERROR: File /etc/os-release not found, cannot determine Linux distribution."
    exit 1
fi

# Install required packages
echo "Installing required packages..."
if [[ $dist_id == ubuntu ]] || [[ $dist_id == debian ]]; then
    apt update -y
    echo "postfix postfix/main_mailer_type select Satellite system" | debconf-set-selections
    echo "postfix postfix/mailname string $maildomain" | debconf-set-selections
    echo "postfix postfix/relayhost string" | debconf-set-selections
    apt install -y postfix bind9-host postfix-lmdb ssl-cert dnsutils
else
    dnf makecache
    dnf install -y postfix bind-utils postfix-lmdb
fi

echo "Getting SPF and MX settings from DNS for $maildomain..."

##############################################################################
# SPF Tools despf function - Extracts IP addresses from SPF records
##############################################################################
spftoolsdespf() {
dns_timeout=${dns_timeout:-"2"}

myhost() { 
    host -W "$dns_timeout" "$@" || { host -W "$dns_timeout" "$@" 1>&2; exit 1; } 
}

get_txt() { 
    myhost -t TXT "$@" | cut -d\" -f2- | sed -e 's/" "//g;s/"$//' 
}

get_mx() { 
    myhost -t MX "$@" | awk '/mail is handled/ {print $NF}' 
}

get_addr() { 
    myhost -t "$@" | awk '/alias/ {print $NF} /address/ {print $NF}' 
}

printip() {
  while read line
  do
    # Don't take the +. It's default
    qualifier=$(echo $line | grep -Eio "^[\\~\\?\\-]")
    line=$(echo $line | sed -e 's/[\\~\\?\\+\\-]//')
    prefix=/${1:-"${line##*/}"}
    test -n "$1" || echo $line | grep -q '/' || prefix=""
    line=$(echo $line | cut -d/ -f1)
    if echo $line | grep -q ':'; then ver=6
      checkval6 $line $prefix || continue
    elif echo $line | grep -q '\.'; then ver=4
      checkval4 $line $prefix || continue
    else
      continue
    fi
    echo "${qualifier}ip${ver}:${line}${prefix}"
  done
}

# dea <hostname> <cidr> <qualifier>
# Get A and AAAA records for a hostname
dea() {
  for TYPE in A AAAA; do
    get_addr $TYPE $1 | while read ip; do 
      addr="${3}${ip}"
      echo $addr | printip $2;
    done
  done
  true
}

# demx <domain> <cidr> <qualifier>
# Get MX record for a domain
demx() {
  mymx=$(get_mx $1)
  for name in $mymx; do dea $name "$2" $3; done
}

# parsepf <host>
# Parse SPF record for a host
parsepf() {
  host=$1
  if [ -n "$dns_server" ]; then
    myns=$dns_server
  else
    myns=$(sed -n 's/^nameserver[     ]//p' /etc/resolv.conf)
  fi
  
  for ns in $myns
  do
    get_txt $host $ns 2>/dev/null \
      | grep -Eio 'v=spf1 [^""]+' && break
  done
}

# getem <includes>
# Process include: directives from SPF records
getem() {
  myloop=$1
  shift
  echo $* | tr " " "\n" | sed '/^$/d' | cut -b 9- | while read included
  do
    # Skip domains with macros (can't be resolved statically)
    if echo "$included" | grep -q '%{'; then
      echo "Skipping (has macros) $included" 1>&2
      echo "include:$included"
    else
      echo "Getting $included" 1>&2
      despf $included $myloop
    fi
  done
}

# getamx host mech [mech [...]]
# Process a: and mx: directives from SPF records
getamx() {
  local cidr ahost
  host=$1
  shift
  for record in $*; do 
    cidr=$(echo $record | cut -s -d\/ -f2-)
    ahost=$(echo $record | cut -s -d: -f2-)
    if [ "x" = "x$ahost" ]; then
      lookuphost="$host"
      mech=$(echo $record | cut -d/ -f1)
    else
      mech=$(echo $record | cut -d: -f1 | cut -d/ -f1)
      if [ "x" = "x$cidr" ]; then
        lookuphost=$ahost
      else
        lookuphost=$(echo $ahost | cut -d\/ -f1)
      fi
    fi
    qualifier=$(echo $mech | grep -Eio "^[\~\?\+\-]")
    mech=$(echo $mech | sed -e 's/[\~\?\+\-]//' | tr '[A-Z]' '[a-z]')
    if [ "$mech" = "a" ]; then
      dea $lookuphost "$cidr" $qualifier
    elif [ "$mech" = "mx" ]; then
      demx $lookuphost "$cidr" $qualifier
    fi
  done
}

# despf <domain>
# Main SPF parsing function
despf() {
  host=$1
  myloop=$2

  # Detect loop
  echo $host | grep -qxFf $myloop && {
    return
  }

  echo "$host" >> "${myloop}"
  myspf=$(parsepf $host | sed 's/redirect=/include:/')

  set +e
  dogetem=$(echo $myspf | grep -Eio 'include:[^[:blank:]]+') && getem $myloop $dogetem
  dogetamx=$(echo $myspf | grep -Eio -w '[\?\~\+\-]?(mx|a)((/|:)[^[:blank:]]+)?') && getamx $host $dogetamx
  echo $myspf | grep -Eio '[\?\~\+\-]?ip[46]:[^[:blank:]]+' | sed -e 's/ip[46]\://'| printip
  echo $myspf | grep -Eio '([\?\~\+\-]?exists|ptr):[^[:blank:]]+'
  set -e
}

cleanup() {
  myloop=$1
  test -n "$myloop" && rm ${myloop}* 2>/dev/null
}

despfit() {
  hosts="$1"
  myloop=$2

  # Make sort(1) behave
  export LC_ALL=C
  export LANG=C 
 
  outputfile=$(mktemp /tmp/despf-sort-XXXXXXX)
  for host in $hosts
  do
    despf $host $myloop
  done > $outputfile
  if grep -E '^[\?\~\-]' $outputfile; then
    cat $outputfile
  else
    sort -u $outputfile
  fi
  rm $outputfile
}

checkval4() {
  ip=$1
  cidr=${2#/}
  test -n "$cidr" && { numlesseq $cidr 32 || return 1; }

  D=$(echo $ip | grep -Eo '\.' | wc -l)
  test $D -eq 3 || return 1
  for i in $(echo $ip | tr '.' ' ')
  do
    numlesseq $i 255 || return 1
  done
}

numlesseq() {
  num=${1:-1}
  less=${2:-255}
  echo "$num" | tr -d '[0-9]' | grep -q '^$' || return 1
  test $num -le $less || return 1
}

checkval6() {
  myip=$(expand6 $1) || return 1
  cidr=${2#/}
  test -n "$cidr" && { numlesseq $cidr 128 || return 1; }

  for i in $(echo $myip | tr ':' ' ')
  do
    C=$(echo $i | wc -c)
    # echo prints a newline --> 5 including \n
    test $C -le 5 || return 1
    echo "$i" | tr -d '[0-9a-fA-F]' | grep -q '^$' || return 1
  done
}

expand6() {
  D=$(echo $1 | grep -Eo ':' | wc -l)
  if test $D -eq 7; then
    echo $1
  elif test $D -le 7 && echo $1 | grep -q '::'; then
    C=$(echo $1 | grep -Eo '::' | wc -l)
    test $C -gt 1 && return 1
    add=""
    for a in $(awk -v MYEND=$((8-$D)) 'BEGIN { for(i=1;i<=MYEND;i++) print i }')
    do
      add=${add}:0000
    done
    out=$(echo $1 | sed "s/::/${add}:/;s/^:/0000:/;s/:$/:0000/")
    out=$(echo $out | sed -E 's/:([0-9]{1})$/:000\1/')
    out=$(echo $out | sed -E 's/:([0-9]{2})$/:00\1/')
    out=$(echo $out | sed -E 's/:([0-9]{3})$/:0\1/')
    echo $out
  else
    return 1
  fi
}

loopfile=$(mktemp /tmp/despf-loop-XXXXXXX)
echo random-non-match-tdaoeinthaonetuhanotehu > "$loopfile"
trap 'cleanup "$loopfile"; exit 1;' INT QUIT
despfit "$maildomain" "$loopfile" | grep . || { 
  echo "ERROR: Failed to retrieve SPF records for $maildomain"
  cleanup "$loopfile"
  exit 1
}
cleanup "$loopfile"
}

##############################################################################
# Main Configuration
##############################################################################

# Get MX records for the domain
echo "Retrieving MX records..."
relaydest=$(host -t MX "$maildomain" 2>/dev/null | awk '/mail is handled/ {print $NF}' | grep -v "$mailhostname" | sed 's/\.$//' | sed 's/$/],/' | sed 's/^/[/' | tr -d '\n' | sed 's/,$//')

if [ -z "$relaydest" ]; then
    echo "ERROR: No MX records found for $maildomain"
    exit 1
fi

# Get SPF records and extract allowed networks
echo "Parsing SPF records..."
spfincludes=$(spftoolsdespf "$maildomain" | sed 's/^ip4://;s/ip6:/[/;s/::/::]/' | tr '\n' ' ')

if [ -z "$spfincludes" ]; then  
  echo "ERROR: No SPF records found for $maildomain"
  exit 1  
fi

echo "Setting up Postfix configuration..."
# Create transport map
echo "$maildomain relay:$relaydest" > /etc/postfix/transport
postmap lmdb:/etc/postfix/transport

# Update main.cf - remove old entries first
sed -i '/^inet_interfaces/d' /etc/postfix/main.cf
sed -i '/^inet_protocols/d' /etc/postfix/main.cf
sed -i '/^transport_maps/d' /etc/postfix/main.cf
sed -i '/^relay_domains/d' /etc/postfix/main.cf
sed -i '/^mynetworks/d' /etc/postfix/main.cf

# Add new configuration
if [[ "$ipv6" == true ]]; then 
  echo "inet_protocols = all" >> /etc/postfix/main.cf
else
  echo "inet_protocols = ipv4" >> /etc/postfix/main.cf
fi
echo "inet_interfaces = all" >> /etc/postfix/main.cf
echo "transport_maps = lmdb:/etc/postfix/transport" >> /etc/postfix/main.cf
echo "relay_domains = $maildomain" >> /etc/postfix/main.cf
echo "mynetworks = $spfincludes" >> /etc/postfix/main.cf

# Enable and restart Postfix
echo "Enabling and starting Postfix..."
systemctl enable postfix
systemctl restart postfix

if systemctl is-active --quiet postfix; then
    echo "SUCCESS: Postfix relay has been configured for $mailhostname and is running"
    echo "  Domain: $maildomain"
    echo "  Relay destination: $relaydest"
    echo "  Allowed networks: $spfincludes"
else
    echo "ERROR: Postfix failed to start. Check logs with: journalctl -xeu postfix"
    exit 1
fi
