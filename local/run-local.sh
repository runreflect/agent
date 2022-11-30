#!/bin/bash

set -e

if [ $# -lt 2 ]; then
  echo "usage: $0 <reflect_api_key> <public_port>"
  exit 1
fi

ReflectApiKey=$1
PublicPort=$2

Host=$(uname)
if [ "$Host" != "Darwin" ]; then
  echo "error: '--local' execution mode only supports Mac OS X"
  exit 1
fi

echo "Reflect Agent running locally on port $PublicPort (use CTRL+C to quit)"

# Move to the source directory and run the entrypoint.
Directory=$(dirname -- $0)
cd ${Directory}/../src/

# Set the local environment and execute the agent.
ReflectEnvironment="osx" ReflectApiKey=$ReflectApiKey PublicPort=$PublicPort ./entrypoint.sh
