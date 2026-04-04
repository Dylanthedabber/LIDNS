#!/bin/bash
set -e

echo "=== LIDNS Setup ==="

# Free up port 53 -- kill anything using it before Docker starts
echo "Checking port 53..."
for svc in dnsdist bind9 named unbound dnsmasq; do
    if systemctl is-active "$svc" &>/dev/null; then
        echo "  Stopping $svc (using port 53)..."
        systemctl stop "$svc"
        systemctl disable "$svc"
    fi
done
# Disable systemd-resolved DNS stub listener if it's on port 53
if ss -tlunp 2>/dev/null | grep -q ':53.*systemd-resolve\|:53.*resolved'; then
    echo "  Disabling systemd-resolved DNS stub..."
    mkdir -p /etc/systemd/resolved.conf.d
    echo -e "[Resolve]\nDNSStubListener=no" > /etc/systemd/resolved.conf.d/lidns.conf
    systemctl restart systemd-resolved
fi
# Last resort: kill whatever process is still on port 53
if ss -tlunp 2>/dev/null | grep -q ':53 '; then
    PIDS=$(ss -tlunp | awk '/:53 /{match($0,/pid=([0-9]+)/,a); if(a[1]) print a[1]}' | sort -u)
    for pid in $PIDS; do
        echo "  Killing PID $pid on port 53..."
        kill "$pid" 2>/dev/null || true
    done
fi

# Free up ports 80 and 443 -- stop system nginx/apache if running
echo "Checking ports 80/443..."
for svc in nginx apache2 httpd lighttpd; do
    if systemctl is-active "$svc" &>/dev/null; then
        echo "  Stopping $svc (using port 80/443)..."
        systemctl stop "$svc"
        systemctl disable "$svc"
    fi
done

# Install Docker if not present
if ! command -v docker &>/dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com | sh
    systemctl enable --now docker
    echo "Docker installed."
else
    echo "Docker already installed."
fi

# Install Docker Compose plugin if not present
if ! docker compose version &>/dev/null 2>&1; then
    echo "Installing Docker Compose plugin..."
    mkdir -p /usr/local/lib/docker/cli-plugins
    COMPOSE_URL="https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)"
    curl -fsSL "$COMPOSE_URL" -o /usr/local/lib/docker/cli-plugins/docker-compose
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
fi

# Open firewall ports if ufw is present
if command -v ufw &>/dev/null && ufw status 2>/dev/null | grep -q 'active'; then
    ufw allow 22/tcp
    ufw allow 53/udp
    ufw allow 53/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    echo "ufw: ports opened."
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "Building and starting LIDNS..."
docker compose up -d --build

echo ""
echo "=== Done ==="
echo "Run 'docker compose logs -f' to watch startup output."
echo "The server IP and port status will appear there."
