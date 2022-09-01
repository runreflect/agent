#!/bin/bash

set -e

if [ $# -lt 3 ]; then
  echo "usage: $0 <reflect-api-key> <public-key> <interval-seconds>"
  exit 1
fi

ReflectApiKey=$1
PublicKey=$2
Seconds=$3

echo "=== Establishing heartbeat check-in"

while true; do

  curl -s -X PUT \
    -o /dev/null \
    -H "X-API-KEY: $ReflectApiKey" \
    https://api.reflect.run/v1/agents/$PublicKey/heartbeat

  sleep $Seconds

done

