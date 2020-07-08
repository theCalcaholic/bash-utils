#! /usr/bin/env bash

TARGET="${1?}"
USER="${2?}"
PUB_KEY="${3?}"
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
