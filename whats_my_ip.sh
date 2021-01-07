#!/usr/bin/env bash

dig -4 @resolver1.opendns.com ANY myip.opendns.com +short | grep -v "failed" \
|| dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | grep -v "timed out" \
|| echo "No DNS services could be reached" >&2
