#!/bin/bash
# made By Surya...!!! (Optimized Native Encryption)

# Create directories
mkdir -p /var/lib/tailscale
mkdir -p /opt/AdGuardHome/work

echo "Starting Tailscale daemon in userspace mode..."
tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &

# Give the daemon 5 seconds to initialize
sleep 5

# Authenticate Tailscale
if [ -n "$TAILSCALE_AUTHKEY" ]; then
    echo "Authenticating Tailscale node..."
    tailscale up --authkey="${TAILSCALE_AUTHKEY}" --ssh --hostname=tails-adguard --accept-dns=false
else
    echo "CRITICAL ERROR: TAILSCALE_AUTHKEY environment variable is missing!"
    exit 1
fi

echo "Preparing AdGuard Home base configuration..."
# Inject schema_version: 34 to bypass the broken config_migrator
cat <<EOF > /opt/AdGuardHome/AdGuardHome.yaml
schema_version: 34
http:
  address: 0.0.0.0:80
dns:
  bind_hosts:
    - 0.0.0.0
  port: 53
  upstream_dns:
    - https://dns.cloudflare.com/dns-query
    - https://dns10.quad9.net/dns-query
  bootstrap_dns:
    - 1.1.1.1
    - 9.9.9.9
EOF

# Add Web UI Authentication
USERNAME="${ADGUARD_USERNAME:-surya}"
PASSWORD="${ADGUARD_PASSWORD:-surya}"
BCRYPT_HASH=$(htpasswd -B -n -b "$USERNAME" "$PASSWORD" | cut -d ":" -f 2)

cat <<EOF >> /opt/AdGuardHome/AdGuardHome.yaml
users:
  - name: "$USERNAME"
    password: "$BCRYPT_HASH"
EOF

echo "Running AdGuard Home boot sequence..."
# Run AdGuard Home in the foreground
cd /opt/AdGuardHome
exec ./AdGuardHome -c /opt/AdGuardHome/AdGuardHome.yaml -w /opt/AdGuardHome/work --no-check-update
