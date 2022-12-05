#!/bin/bash

Destination="/usr/local/bin/"

echo "This script downloads and builds 3proxy from GitHub."
echo "Installation to ($Destination) requires sudo, and is assumed to be on the PATH."
echo -n "Press any key to begin: "
read

HasGcc=$(which gcc)
HasCurl=$(which curl)
if [[ -z $HasGcc ]] || [[ -z $HasCurl ]]; then
  echo "error: this script requires gcc and curl to install 3proxy"
  exit 1
fi

ThreeProxyVersion=0.9.4
ArchiveFile=3proxy.tar.gz

curl -L -o $ArchiveFile https://github.com/3proxy/3proxy/archive/refs/tags/${ThreeProxyVersion}.tar.gz
tar -xf $ArchiveFile
rm $ArchiveFile

mv 3proxy* 3proxy
cd 3proxy/
make -f Makefile.FreeBSD

echo "Installing the 3proxy binary into ($Destination), this requires sudo permissions:"
sudo mv bin/3proxy /usr/local/bin/3proxy

cd ../
rm -fr ./3proxy/
