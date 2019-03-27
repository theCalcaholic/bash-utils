#!/usr/bin/env bash

openssl x509 -in "$1" -text -noout
