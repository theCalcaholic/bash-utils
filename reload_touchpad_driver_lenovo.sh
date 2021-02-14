#!/usr/bin/env bash

# >parse_args< to trigger readme generator
if [[ " $@ " =~ .*(" --help "|" -h ").* ]]
then
  echo "Usage: reload_touchpad_driver_lenovo.sh

  Must be executed as root"
  exit 0
fi

[[ "$(id -u)" == "0" ]] || {
    echo "Error: This script must be executed as root (try using 'sudo')!"
    exit 1
}

modprobe -r psmouse && modprobe psmouse
