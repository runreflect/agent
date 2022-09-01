#!/bin/bash

set -e

if [ $# -lt 5 ]; then
  echo "usage: $0 <wireguard-ip> <wireguard-port> <private-key> <peer-public-key> <peer-ips>"
  exit 1
fi

WireguardIp=$1
WireguardPort=$2
PrivateKey=$3
PeerPublicKey=$4
PeerIps=$5

WireguardConfigFile="/etc/wireguard/wg0.conf"

echo "=== Installing Wireguard ($WireguardConfigFile) for $WireguardIp:$WireguardPort"

cat << EOF > $WireguardConfigFile
[Interface]
Address = $WireguardIp
PrivateKey = $PrivateKey
ListenPort = $WireguardPort

[Peer]
PublicKey = $PeerPublicKey
AllowedIPs = $PeerIps
EOF

echo "=== Bringing up Wireguard interface"

wg-quick up $WireguardConfigFile

