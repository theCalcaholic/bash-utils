#! /usr/bin/env bash

DESCRIPTION="Checks the download and upload rates against a given target (where an iperf daemon needs to be running) and prints it in a parseable format together with the current gateway mac address (to allow filtering for networks)"
USAGE="iperf-log.sh target username rsa-public-key-path

    target: The target IP to test up-/download rates against (requires iperf to be running on the target host)
    username: The username to use for authentication at the target host
    rsa-public-key-path: The path to the public key that will be used for encrypting the iperf credentials

    If the file \$HOME/iperf_pw exists, it will be expected to contain a valid iperf password for the target host. Otherwise, the script will ask for the password interactively."

set -e
. "$(dirname "$BASH_SOURCE")/lib/parse_args.sh"
REQUIRED=("target" "username" "rsa-public-key-path")
parse_args __USAGE "$USAGE" __DESCRIPTION "$DESCRIPTION" "$@"
set_trap 1 2


TARGET="${NAMED_ARGS["target"]}"
USER="${NAMED_ARGS["username"]}"
PUB_KEY="${NAMED_ARGS["rsa-public-key-path"]}"

[[ -f "$HOME/iperf_pw" ]] && export IPERF3_PASSWORD="$(cat $HOME/iperf_pw)"

upload_results="$(iperf3 -c "${TARGET}" --username "${USER}" --rsa-public-key-path "${PUB_KEY}")"
download_results="$(iperf3 -c "${TARGET}" --username "${USER}" --rsa-public-key-path "${PUB_KEY}" -R)"

download_rate="$(echo "$download_results" | grep -B 4 'iperf Done.' | grep 'receiver' | awk '{ print $7 }')"
upload_rate="$(echo "$upload_results" | grep -B 4 'iperf Done.' | grep 'sender' | awk '{ print $7 }')"

#echo "$download_results"
#echo ""
#echo "$download_results" | grep -A 3 'Summary Results'

gateway_ip="$(ip -j route | jq '.[] | select(.dst=="default") | .gateway' -r | head -n 1)"
gateway_mac="$(ip neigh | grep REACHABLE | grep "$gateway_ip" | awk '{print $(NF-1)}')"

[[ -z "$gateway_mac" ]] && gateway_mac="???"

echo "$(date --iso-8601=m)|$gateway_mac|DOWN|${download_rate}"
echo "$(date --iso-8601=m)|$gateway_mac|UP|${upload_rate}"

