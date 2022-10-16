#!/bin/bash

set -e

if [ $# -lt 5 ]; then
  echo "usage: $0 <reflect-api-key> <private-key> <public-key> <public-port> <interval-seconds>"
  exit 1
fi

ReflectApiKey=$1
PrivateKey=$2
PublicKey=$3
PublicPort=$4
Seconds=$5

ResponseFile="heartbeat-response.json"
SessionsFile="sessions.json"
LastSHA=""

echo "agent: initiating heartbeat"

EncodedPublicKey=$(echo $PublicKey | jq -R -r @uri)

while true; do

  curl -s -X PUT \
    -o $ResponseFile \
    -H "X-API-KEY: $ReflectApiKey" \
    https://api.reflect.run/v1/agents/$EncodedPublicKey/heartbeat

  CurrentSHA=$(sha256sum $ResponseFile)

  if [ "$CurrentSHA" != "$LastSHA" ]; then
    # Update the wireguard configuration since the sessions have changed.

    WireguardIp=$(jq -r '.privateIp' $ResponseFile)
    jq -r '.activeSessions' $ResponseFile > $SessionsFile

    ./wireguard.sh $WireguardIp $PrivateKey $PublicPort $SessionsFile

  fi

  LastSHA=$CurrentSHA

  sleep $Seconds

done
