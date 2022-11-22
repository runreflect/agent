#!/bin/bash

set -e

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

./keypair.sh $PrivateKeyFile $PublicKeyFile

PrivateKey=$(cat $PrivateKeyFile)
PublicKey=$(cat $PublicKeyFile)

touch $MessagesFile
./connect.sh $ReflectApiKey $PublicKey $MessagesFile &

./monitor.sh $PrivateKey $PublicPort $MessagesFile &

sleep infinity &
wait $!

# Never hit.
echo "agent: done"
