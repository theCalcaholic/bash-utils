#!/usr/bin/env bash

#set > ~/set_vars_script

set -e
shopt -s extglob

USAGE="lower-vpn-priority.sh [OPTIONS]

  Options:
    -p, --priority <value> Sets the new route priority to the given value (default: 101)

  Must be executed as root"
DESCRIPTION="Lowers your VPNs default route priority to 101"

. "$(dirname "$BASH_SOURCE")/lib/parse_args.sh"
KEYWORDS=("-p" "--priority")
parse_args __USAGE "$USAGE" __DESCRIPTION "$DESCRIPTION" "$@"
priority="${KW_ARGS['--priority']-${KW_ARGS['-p']}}"

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
ip route add ${vpn_route/metric +([0-9])/metric ${priority:-101}} || {
  echo "ERROR: Could not recreate vpn route! Your network device 'tun0' (hopefully your vpn) might not work correctly. If you encounter issues, try reconnecting.
Alternatively, execute the command 'sudo ip route add ${vpn_route/metric +([0-9])/metric 101}' yourself."
  exit 3
}

