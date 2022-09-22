#!/bin/bash

set -e

if [ $# -lt 4 ]; then
  echo "usage: $0 <reflect-api-key> <public-key> <public-port> <response-outfile>"
  exit 1
fi

ReflectApiKey=$1
PublicKey=$2
PublicPort=$3
ResponseFile=$4

RequestFile=request.json

echo "=== Registering agent ==="

cat << EOF > $RequestFile
{
  "publicKey": "${PublicKey}",
  "port": $PublicPort
}
EOF

RequestString=$(jq -c '.' $RequestFile)

curl -s -X POST \
  --data-raw "$RequestString" \
  -o $ResponseFile \
  -H "X-API-KEY: $ReflectApiKey" \
  https://api.reflect.run/v1/agents

echo "=== Registration response in '$ResponseFile'"
