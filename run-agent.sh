#!/bin/bash

PublicPort=10009
WithNat="false"

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
  echo -e "\t-n"
  echo -e "\t\tUse a persistent connection to Reflect when behind a NAT, default $WithNat"
  echo
  exit 1
}

while getopts ":k:p:n" option; do
    case "${option}" in
        k)
            ReflectApiKey=${OPTARG}
            ;;
        p)
            PublicPort=${OPTARG}
            ;;
        n)
            WithNat="true"
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
  -e WithNat=$WithNat \
  -p $PublicPort:$PublicPort/udp \
  agent
