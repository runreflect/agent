#!/bin/bash

set -e

if [ $# -lt 3 ]; then
  echo "usage: $0 <private-key> <public-port> <messages-file>"
  exit 1
fi

PrivateKey=$1
PublicPort=$2
MessagesFile=$3

SleepTime="0.3"
SessionsFile="sessions.json"
ProxyStarted="false"
LastSessions=""

echo "agent: activating monitor"

while true; do

  CurrentSessions=$(tail -1 $MessagesFile)

  if [ "$CurrentSessions" != "" ] && [ "$CurrentSessions" != "$LastSessions" ]; then
    # Update the proxy and wireguard configuration since the sessions have changed.

    if [ "$ProxyStarted" == "false" ]; then
      # Eventually, this could be killed and relaunched if the proxy IP changed.
      # But that should be so rare as to be easily handled by restarting the agent.
      ProxyIp=$(echo "$CurrentSessions" | jq -r '.proxyIp')
      ProxyPort=$(echo "$CurrentSessions" | jq -r '.proxyPort')
      ./proxy.sh $ProxyIp $ProxyPort

      ProxyStarted="true"
    fi

    WireguardIp=$(echo "$CurrentSessions" | jq -r '.privateIp')
    echo "$CurrentSessions" | jq -r '.activeSessions' > $SessionsFile

    ./wireguard.sh $WireguardIp $PrivateKey $PublicPort $SessionsFile

  fi

  LastSessions=$CurrentSessions

  sleep $SleepTime

done
