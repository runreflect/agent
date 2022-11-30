#!/bin/bash

PublicPort=10009

function usage {
  echo "usage: $0 [--local] -k <reflect_api_key> [-p <public_port>]"
  echo -e "\tRuns the Reflect Agent and connects to the specified Reflect account"
  echo
  echo -e "\t--local"
  echo -e "\t\tRuns the agent without Docker isolation on the local machine."
  echo -e "\t\tThis requires installing several utility program dependencies."
  echo -e "\t\tSee the 'local/check-dependency.sh' and 'local/install...' scripts."
  echo -e "\t\tNOTE: this mode requires 'sudo' since it modifies network interfaces."
  echo
  echo -e "\t-k reflect_api_key"
  echo -e "\t\tThe API key for the Reflect account"
  echo
  echo -e "\t-p public_port"
  echo -e "\t\tThe public port on the host machine, default $PublicPort"
  echo
  exit 1
}

if [ "$1" == "--local" ]; then
  IsLocal="true"
  shift
fi

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

if [ "$IsLocal" == "true" ]; then
  Directory=$(dirname -- $0)
  $Directory/local/run-local.sh $ReflectApiKey $PublicPort

  LocalAgentExit=$?
  if [ "$LocalAgentExit" != "0" ]; then
    echo "Reflect Agent exited unexpectedly: $LocalAgentExit"
  else
    echo "Reflect Agent exited successfully"
  fi

else
  echo "Reflect Agent running on port $PublicPort"

  docker run --rm --cap-add net_admin -d \
    --name agent \
    -e ReflectApiKey=$ReflectApiKey \
    -e PublicPort=$PublicPort \
    -p $PublicPort:$PublicPort/udp \
    agent

  # The agent daemon is stopped using 'stop-agent.sh'.
fi
