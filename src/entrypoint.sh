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

echo "=== Reflect Agent ==="

PrivateKeyFile="private.key"
PublicKeyFile="public.key"
RegistrationResponseFile="response.json"

./keypair.sh $PrivateKeyFile $PublicKeyFile

PublicKey=$(cat $PublicKeyFile)
./register.sh $ReflectApiKey $PublicKey $PublicPort $RegistrationResponseFile

ProxyIp=$(jq -r '.proxyIp' $RegistrationResponseFile)
ProxyPort=$(jq -r '.proxyPort' $RegistrationResponseFile)
./proxy.sh $ProxyIp $ProxyPort

WireguardIp=$(jq -r '.privateIp' $RegistrationResponseFile)
PrivateKey=$(cat $PrivateKeyFile)
PeerPublicKey=$(jq -r '.sessionsPublicKey' $RegistrationResponseFile)
PeerIps=$(jq -r '.sessionsIpsNetmask | join(", ")' $RegistrationResponseFile)
./wireguard.sh $WireguardIp $PublicPort $PrivateKey $PeerPublicKey $PeerIps

HeartbeatIntervalSecs=600
./heartbeat.sh $ReflectApiKey $PublicKey $HeartbeatIntervalSecs

sleep infinity &
wait $!

echo "done"
