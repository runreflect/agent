#!/bin/bash

if [ $# -lt 1 ]; then
  echo "usage: $0 <reflect-api-key> [public-port]"
  exit 1
fi

ReflectApiKey=$1
PublicPort="${2:-10009}"

echo "=== Running Reflect Agent ==="
echo "PublicPort=$PublicPort"

docker run --rm --cap-add net_admin -d \
  --name agent \
  -e ReflectApiKey=$ReflectApiKey \
  -e PublicPort=$PublicPort \
  -p $PublicPort:$PublicPort/udp \
  agent
