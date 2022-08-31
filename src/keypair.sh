#!/bin/bash

set -e

if [ $# -lt 2 ]; then
  echo "usage: $0 <private-key-outfile> <public-key-outfile>"
  exit 1
fi

PrivateKeyOutfile=$1
PublicKeyOutfile=$2

echo "=== Generating keypair ==="

PrivateKey=$(wg genkey)
PublicKey=$(echo $PrivateKey | wg pubkey)

echo $PrivateKey > $PrivateKeyOutfile
echo $PublicKey > $PublicKeyOutfile

echo "Wrote keys: priv=$PrivateKeyOutfile, pub=$PublicKeyOutfile"

