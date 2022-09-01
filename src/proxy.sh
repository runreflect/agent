#!/bin/bash

set -e

if [ $# -lt 2 ]; then
  echo "usage: $0 <proxy-ip> <proxy-port>"
  exit 1
fi

ProxyIp=$1
ProxyPort=$2

ProxyCIDR="${ProxyIp}/24"
ProxyDevice="proxy0"
ProxyBinary="/opt/reflect-agent/3proxy"

echo "=== Creating proxy interface ($ProxyDevice)"

ip link add dev $ProxyDevice type dummy
ip address add dev $ProxyDevice $ProxyCIDR
ip link set up dev $ProxyDevice

echo "=== Running proxy at ${ProxyIp}:${ProxyPort}"

ProxyConfig="socks -p${ProxyPort} -i${ProxyIp}"
echo $ProxyConfig | $ProxyBinary &

