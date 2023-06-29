#!/bin/bash

# Echo the SessionsCommand every interval, for X intervals.
# This is used in conjunction with the connect.sh script
# to maintain a persistent connection to the Reflect API,
# which is distinct from the individual browser (Wireguard) connections.

if [ $# -lt 2 ]; then
  echo "usage: $0 <interval-secs> <num-intervals>"
  exit 1
fi

IntervalSeconds=$1
TotalIntervals=$2
CurrentInterval=0

SessionsCommand="sessions"

while (( ++CurrentInterval <= TotalIntervals )); do
  echo $SessionsCommand

  if [ "$CurrentInterval" != "$TotalIntervals" ]; then
    sleep $IntervalSeconds
  fi
done
