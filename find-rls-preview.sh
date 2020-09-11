#!/bin/bash
MAC=false
date -r "$now" +%Y-%m-%d &> /dev/null
if [ "$?" -ne "0" ]; then echo "LINUX"; MAC=false; else echo 'MAC'; MAC=true; fi

now=`date +%s`

while true
do
  if [ "$MAC" == "true" ]; then data=`date -r "$now" +%Y-%m-%d`; else data=`date -d @"$now" +%Y-%m-%d`; fi
  echo $data
  str=`curl -s https://static.rust-lang.org/dist/$data/channel-rust-nightly.toml | grep rls-preview`
  if [ "$str" != "" ]; then echo "Bingo!"; break; fi
  now=$(($now-86400))
done