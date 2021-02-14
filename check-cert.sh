#!/usr/bin/env bash

. "$(dirname $BASH_SOURCE)/lib/parse_args.sh"
declare -a REQUIRED=("x509_cert_file")
set_trap 1 2
parse_args __DESCRIPTION "Get openssl information on x509_cert_file" \
  __USAGE "check-cert.sh x509_cert_file" "$@"

openssl x509 -in "${NAMED_ARGS["x509_cert_file"]}" -text -noout

