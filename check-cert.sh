#!/usr/bin/env bash

. "$(dirname $0)/lib/parse_args.sh"
set_trap 1 2
parse_args __DESCRIPTION "Get openssl information on x509_cert_file" \
  __USAGE "check-cert.sh x509_cert_file" "$@"

openssl x509 -in "$1" -text -noout

