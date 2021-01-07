#!/usr/bin/env bash

if [[ " $* " =~ .*(" --help "|" -h ").* ]]
then
  echo "DESCRIPTION: Get openssl information about x509_cert_file"
  echo "USAGE: check-cert.sh x509_cert_file"
  exit 0
fi

openssl x509 -in "$1" -text -noout
