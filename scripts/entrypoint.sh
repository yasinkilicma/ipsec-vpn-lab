#!/bin/sh

# LAN IP'yi loopback'e ata
ip addr add "$LAN_IP" dev lo 2>/dev/null || echo "Lo: $LAN_IP OK (veya hata)"
ip link set lo up

# strongSwan'i baslat
echo "Starting strongSwan..."
exec ipsec start --nofork
