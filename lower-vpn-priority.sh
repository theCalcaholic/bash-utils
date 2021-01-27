#!/usr/bin/env bash

#set > ~/set_vars_script

set -e
shopt -s extglob

USAGE="lower-vpn-priority.sh
  Requires"
DESCRIPTION="Lowers your VPNs default route priority to 101"

. "$(dirname "$0")/lib/parse_args.sh"
#set_trap 1
parse_args __USAGE "$USAGE" __DESCRIPTION "$DESCRIPTION" "$@"

if [[ "$EUID" -ne 0 ]]
then
  echo "ERROR: You need to be root. Try 'sudo lower-vpn-priority.sh'"
  exit 1
fi

vpn_route="$(ip route list match default dev tun0)"
if [[ -z "$vpn_route" ]]
then
  echo "ERROR: Could not find route to replace!"
  exit 2
fi

ip route del $vpn_route
ip route add ${vpn_route/metric +([0-9])/metric 101} || {
  echo "ERROR: Could not recreate vpn route! Your network device 'tun0' (hopefully your vpn) might not work correctly. If you encounter issues, try reconnecting.
Alternatively, execute the command 'sudo ip route add ${vpn_route/metric +([0-9])/metric 101}' yourself."
  exit 3
}

