#!/bin/bash

PublicPort=10009

function usage {
  echo "usage: $0 -k <reflect_api_key> [-p <public_port] [-n]"
  echo -e "\tRuns the Reflect Agent and connects to the specified Reflect account"
  echo
  echo -e "\t-k reflect_api_key"
  echo -e "\t\tThe API key for the Reflect account"
  echo
  echo -e "\t-p public_port"
  echo -e "\t\tThe public port on the host machine, default $PublicPort"
  echo
  exit 1
}

while getopts ":k:p:" option; do
    case "${option}" in
        k)
            ReflectApiKey=${OPTARG}
            ;;
        p)
            PublicPort=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${ReflectApiKey}" ]; then
    usage
fi

echo "Reflect Agent running on port $PublicPort"

docker run --rm --cap-add net_admin -d \
  --name agent \
  -e ReflectApiKey=$ReflectApiKey \
  -e PublicPort=$PublicPort \
  -p $PublicPort:$PublicPort/udp \
  agent
