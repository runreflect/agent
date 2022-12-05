#!/bin/bash

if [ -z "$ReflectApiKey" ]; then
  echo "Missing environment variable 'ReflectApiKey'"
  exit 1
fi

if [ -z "$PublicPort" ]; then
  echo "Missing environment variable 'PublicPort'"
  exit 1
fi

echo "agent: starting"

PrivateKeyFile="private.key"
PublicKeyFile="public.key"
MessagesFile="messages.txt"
SessionsFile="sessions.json"

# Trap ctrl+c to clean-up before quitting.
trap cleanup INT SIGKILL

function cleanup() {
  echo "agent: cleaning up..."

  if [ $ConnectPid ]; then
    kill -9 $ConnectPid 2>/dev/null
  fi

  if [ $MonitorPid ]; then
    Children=$(pgrep -P $MonitorPid)
    for ChildPid in $Children; do
      # Look one more level to find the proxy binary.
      Grandchildren=$(pgrep -P $ChildPid)
      for GrandchildPid in $Grandchildren; do
        kill -9 $GrandchildPid
      done
      kill -9 $ChildPid 2>/dev/null
    done
    kill -9 $MonitorPid 2>/dev/null
  fi

  rm -f $PrivateKeyFile $PublicKeyFile $MessagesFile $SessionsFile

  echo "agent: exiting"
  if [ -z $1 ]; then
    exit 0
  else
    exit $1
  fi
}

function isProcessFailed() {
  if [ $1 ]; then
    Alive=$(ps | awk '{ print $1 }' | grep $1)
    if [ -z "$Alive" ]; then
      echo "true"
    fi
  fi
}

function ensureLivenessOrExit() {
  ConnectFailed=$(isProcessFailed "$ConnectPid")
  MonitorFailed=$(isProcessFailed "$MonitorPid")

  if [[ "$ConnectFailed" == "true" || "$MonitorFailed" == "true" ]]; then
    echo "agent: failure in connect=$ConnectFailed, or monitor=$MonitorFailed"
    cleanup "1"
  fi
}

./keypair.sh $PrivateKeyFile $PublicKeyFile

PrivateKey=$(cat $PrivateKeyFile)
PublicKey=$(cat $PublicKeyFile)

touch $MessagesFile
./connect.sh $ReflectApiKey $PublicKey $MessagesFile &
ConnectPid=$!

./monitor.sh $PrivateKey $PublicPort $MessagesFile $SessionsFile &
MonitorPid=$!

while true; do
  ensureLivenessOrExit
  sleep 5;
done

# Never hit.
echo "agent: done"
