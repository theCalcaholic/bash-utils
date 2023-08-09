#!/usr/bin/env bash

set -e
USAGE="delete-bridge.sh bridge-id"
DESCRIPTION="Deletes given bridge"

. "$(dirname "$BASH_SOURCE")/lib/parse_args.sh"
REQUIRED=("bridge")
parse_args __USAGE "$USAGE" __DESCRIPTION "$DESCRIPTION" "$@"

if [[ "$EUID" -ne 0 ]]
then
  echo "ERROR: You need to be root. Try 'sudo delete-bridge.sh'" >&2
  exit 1
fi

ip link set "${NAMED_ARGS[bridge]}" down
brctl delbr "${NAMED_ARGS[bridge]}"

