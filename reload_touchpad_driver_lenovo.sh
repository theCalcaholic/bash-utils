#!/usr/bin/env bash

[[ "$(id -u)" == "0" ]] || {
    echo "Error: This script must be executed as root (try using 'sudo')!"
    exit 1
}

modprobe -r psmouse && modprobe psmouse
