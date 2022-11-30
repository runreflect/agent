#!/bin/bash

set -e

if [ $# -lt 2 ]; then
  echo "usage: $0 <private-key-outfile> <public-key-outfile>"
  exit 1
fi

PrivateKeyOutfile=$1
PublicKeyOutfile=$2

echo "agent: generating keypair"

PrivateKey=$(wg genkey)
PublicKey=$(echo $PrivateKey | wg pubkey)

echo $PrivateKey > $PrivateKeyOutfile
echo $PublicKey > $PublicKeyOutfile

echo "agent: wrote keys (priv=$PrivateKeyOutfile, pub=$PublicKeyOutfile)"
