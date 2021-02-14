#!/usr/bin/env bash

# >parse_args< to trigger readme generator
print_usage() {
  echo "Prints your public IP (by querying opendns or, as fallback, google's dns server)"
  echo "USAGE:
  whats_my_ip.sh"
}

if [[ " $@ " =~ .*(" -h "|" --help ").* ]]
then
  print_usage
  exit 0
fi

dig +short -4 @resolver1.opendns.com a myip.opendns.com | grep -v "failed" \
  || dig +short -6 myip.opendns.com aaaa @resolver1.ipv6-sandbox.opendns.com | grep -v "failed" \
  || dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | grep -v "timed out" \
  || echo "No DNS services could be reached" >&2

