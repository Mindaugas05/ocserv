#!/bin/sh
set -eu

echo "[+] Starting ocserv lab"

echo "[+] Container interfaces:"
ip addr

echo
echo "[+] Routes:"
ip route

echo
echo "[+] Enabling IPv4 forwarding..."
sysctl -w net.ipv4.ip_forward=1

echo "[+] Configuring VPN NAT..."

# Remove an existing rule if one exists.
iptables -t nat -D POSTROUTING \
    -s 10.10.10.0/24 \
    -o eth0 \
    -j MASQUERADE 2>/dev/null || true

iptables -t nat -A POSTROUTING \
    -s 10.10.10.0/24 \
    -o eth0 \
    -j MASQUERADE

echo "[+] Configuring forwarding..."

iptables -D FORWARD \
    -s 10.10.10.0/24 \
    -o eth0 \
    -j ACCEPT 2>/dev/null || true

iptables -D FORWARD \
    -d 10.10.10.0/24 \
    -i eth0 \
    -m conntrack \
    --ctstate ESTABLISHED,RELATED \
    -j ACCEPT 2>/dev/null || true

iptables -A FORWARD \
    -s 10.10.10.0/24 \
    -o eth0 \
    -j ACCEPT

iptables -A FORWARD \
    -d 10.10.10.0/24 \
    -i eth0 \
    -m conntrack \
    --ctstate ESTABLISHED,RELATED \
    -j ACCEPT

echo
echo "[+] Starting ocserv..."

exec ocserv \
    -c /etc/ocserv/ocserv.conf \
    -f
