#!/bin/bash

set -e

function usage {
  local msg=$1
  echo
  echo "ERROR: $msg"
  echo
  echo "Usage:"
  echo "./sftp-run.sh <root> <organization>"
  echo
  exit -1
}

root=$1
organization=$2

[[ -z $root ]]         && usage 'missing root argument'
[[ -z $organization ]] && usage 'missing organization argument'

ls $root/data/$organization > /dev/null

docker run -it \
  --volumes-from sftp.$organization \
  wherewithal/sftp \
  passwd wherewithal
