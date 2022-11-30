#!/bin/bash

# Exit if either the proxy or wireguard commands fail.
set -e

if [ $# -lt 4 ]; then
  echo "usage: $0 <private-key> <public-port> <messages-file> <sessions-file>"
  exit 1
fi

PrivateKey=$1
PublicPort=$2
MessagesFile=$3
SessionsFile=$4

SleepTime="0.3"
LastSessions=""

echo "agent: activating monitor"

function isProxyAlive() {
  [[ -z $ProxyPid ]] || [[ $(ps | awk '{print $1}' | grep $ProxyPid) ]]
}

while isProxyAlive; do

  CurrentSessions=$(tail -1 $MessagesFile 2>/dev/null)

  if [ "$CurrentSessions" != "" ] && [ "$CurrentSessions" != "$LastSessions" ]; then
    # Update the proxy and wireguard configuration since the sessions have changed.

    if [ -z "$ProxyPid" ]; then
      # Eventually, this could be killed and relaunched if the proxy IP changed.
      # But that should be so rare as to be easily handled by restarting the agent.
      ProxyIp=$(echo "$CurrentSessions" | jq -r '.proxyIp')
      ProxyPort=$(echo "$CurrentSessions" | jq -r '.proxyPort')
      ./proxy.sh $ProxyIp $ProxyPort &
      ProxyPid=$!
    fi

    WireguardIp=$(echo "$CurrentSessions" | jq -r '.privateIp')
    echo "$CurrentSessions" | jq -r '.activeSessions' > $SessionsFile

    ./wireguard.sh $WireguardIp $PrivateKey $PublicPort $SessionsFile

  fi

  LastSessions=$CurrentSessions

  sleep $SleepTime

done
