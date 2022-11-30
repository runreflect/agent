#!/bin/bash

if [ $# -lt 2 ]; then
  echo "usage: $0 <proxy-ip> <proxy-port>"
  exit 1
fi

ProxyIp=$1
ProxyPort=$2

Interface="lo:0"
ProxyBinary="/opt/reflect-agent/3proxy"
InterfaceCommandSuffix=""

if [ "$ReflectEnvironment" == "osx" ]; then
  Interface="lo0"
  ProxyBinary="3proxy"
  InterfaceCommandSuffix="alias"
fi

# Confirm the proxy binary exists.
BinaryPath=$(which $ProxyBinary)
if [ -z "$BinaryPath" ]; then
  echo "agent: error - proxy binary is missing or not on path"
  exit 1
fi

echo "agent: adding alias to interface ($Interface) for proxy IP ($ProxyIp)"
ifconfig $Interface inet $ProxyIp netmask 255.255.255.0 $InterfaceCommandSuffix

# Run the proxy
echo "agent: running proxy at ${ProxyIp}:${ProxyPort}"

ProxyConfig="socks -p${ProxyPort} -i${ProxyIp}"
echo $ProxyConfig | $ProxyBinary
