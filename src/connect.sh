#!/bin/bash

set -e

if [ $# -lt 3 ]; then
  echo "usage: $0 <reflect-api-key> <public-key> <output-file>"
  exit 1
fi

ReflectApiKey=$1
PublicKey=$2
OutputFile=$3

EncodedPublicKey=$(echo $PublicKey | jq -R -r @uri)

IntervalSeconds=55
TotalIntervals=11
RestartSeconds=0.3

echo "agent: connecting"

while true; do

  # Periodically echo the "sessions" command to improve the chances of the websocket staying alive.
  # But still reset and reconnect every 10 minutes or so, or if the server drops the connection.
  ./output.sh $IntervalSeconds $TotalIntervals | \
    websocat wss://agent.reflect.run/api/agents/${EncodedPublicKey} \
    -H "X-API-KEY:${ReflectApiKey}" | \
    tee $OutputFile

  # If the server disconnects due to a deployment or failure, reconnect.
  sleep $RestartSeconds
  echo "agent: reconnecting"
done
