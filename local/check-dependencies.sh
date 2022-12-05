#!/bin/bash

echo "Verifying agent dependencies"
echo "-----------------------------"

ExitCode=0

function pad() {
  Result="                  $1"
  echo "${Result: -18}"
}

function passed() {
  echo -e "\xE2\x9C\x85 passed"
}

function failed() {
  ExitCode=1
  echo -e "\xE2\x9D\x8C failed"
}

function missingCommands() {
  for command in "$@"; do
    Exists=$(which $command)
    if [ -z $Exists ]; then
      echo "true" && break
    fi
  done
}

function checkDependency() {
  Name=$(pad $1)
  shift
  Missing=$(missingCommands $@)

  echo -ne "${Name}: "
  if [ $Missing ]; then failed ; else passed ; fi
}

checkDependency "ifconfig" "ifconfig"
checkDependency "wireguard-tools" "wg" "wg-quick"
checkDependency "jq" "jq"
checkDependency "websocat" "websocat"
checkDependency "3proxy" "3proxy"

exit $ExitCode
