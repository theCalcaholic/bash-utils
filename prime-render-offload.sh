#!/usr/bin/env bash

# >parse_args< to trigger readme generator
if [[ " $* " =~ .*(" -h "|" --help ").* ]]
then
  echo "DESCRIPTION: Executes command with required environment variables to enable NVIDIA prime offload rendering."
  echo "USAGE:
  prime_render_offload.sh command [args]"
  exit 0
fi

__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia $@

