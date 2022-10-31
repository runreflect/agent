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
RegistrationResponseFile="registration-response.json"
HeartbeatIntervalSecs=5

./keypair.sh $PrivateKeyFile $PublicKeyFile

PrivateKey=$(cat $PrivateKeyFile)
PublicKey=$(cat $PublicKeyFile)

./register.sh $ReflectApiKey \
  $PublicKey $PublicPort \
  $RegistrationResponseFile

ProxyIp=$(jq -r '.proxyIp' $RegistrationResponseFile)
ProxyPort=$(jq -r '.proxyPort' $RegistrationResponseFile)
./proxy.sh $ProxyIp $ProxyPort

./heartbeat.sh $ReflectApiKey \
  $PrivateKey $PublicKey $PublicPort \
  $HeartbeatIntervalSecs &

sleep infinity &
wait $!

# Never hit.
echo "agent: done"
