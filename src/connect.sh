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

SessionsCommand="sessions"

echo "agent: connecting"

while true; do

  # This initial command causes the server to immediately send the active session after connection.
  # The stdin stream actually closes after echo completes, so no further commands can be sent.
  # That's fine since the agent simply listens for messages after its initial command.
  # The -n flag below is required to ensure that websocat stays open even after stdin EOF.
  echo $SessionsCommand | \
    websocat -n wss://agent.reflect.run/api/agents/${EncodedPublicKey} \
    -H "X-API-KEY:${ReflectApiKey}" | \
    tee $OutputFile

  # If the server disconnects due to a deployment or failure, reconnect.
  sleep 1
  echo "agent: reconnecting"
done
