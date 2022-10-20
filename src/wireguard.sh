#!/bin/bash

set -e

# This inherits the WithNat environment variable from entrypoint.sh.

if [ $# -lt 4 ]; then
  echo "usage: $0 <wireguard-ip> <private-key> <wireguard-port> <peers-file>"
  exit 1
fi

WireguardIp=$1
PrivateKey=$2
WireguardPort=$3
PeersFile=$4

UdpPunchIp="0.0.0.0"
WireguardConfigFile="/etc/wireguard/wg0.conf"

echo "agent: installing wireguard ($WireguardConfigFile) for $WireguardIp:$WireguardPort"

# Create the initial configuration.
cat << EOF > $WireguardConfigFile
[Interface]
Address = $WireguardIp
PrivateKey = $PrivateKey
ListenPort = $WireguardPort

EOF

# Append each peer to the configuration.
cat $PeersFile | \
  jq -r \
  '.[] | .publicKey + " " + .allowedIp + " " + .endpoint.ip + " " + (.endpoint.port|tostring)' | \
  while read Key AllowedIp EndpointIp EndpointPort; do
    Endpoint="${EndpointIp}:${EndpointPort}"

    if [ "${WithNat}" == "true" ]; then
      echo "agent: sending datagram to $Endpoint"
      ./udp-punch $UdpPunchIp $WireguardPort $EndpointIp $EndpointPort
    fi

    echo "[Peer]" >> $WireguardConfigFile
    echo "PublicKey = $Key" >> $WireguardConfigFile
    echo "AllowedIPs = $AllowedIp" >> $WireguardConfigFile
    echo "Endpoint = $Endpoint" >> $WireguardConfigFile

    if [ "${WithNat}" == "true" ]; then
      echo "PersistentKeepalive = 25" >> $WireguardConfigFile
    fi

    echo >> $WireguardConfigFile
  done

echo "agent: toggling wireguard interface"

IsRunning=$(wg | wc -c) # Hack to determine if it's running
if [ "$IsRunning" != "0" ]; then
  wg-quick down $WireguardConfigFile
fi

wg-quick up $WireguardConfigFile
