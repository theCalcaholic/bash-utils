#!/usr/bin/env bash

# >parse_args< to trigger readme generator
print_usage() {
  echo "Sets up a virtual mic and output to allow e.g. sharing your system sound to a video call (using pulseaudio volume control)"
  echo "USAGE:
  virtual-mic.sh"
}

if [[ " $@ " =~ .*(" -h "|" --help ").* ]]
then
  print_usage
  exit 0
fi

DEFAULT_SINK="$(pactl info | grep 'Default Sink:')"
DEFAULT_SINK="${DEFAULT_SINK##*Default Sink: }"
DEFAULT_SOURCE="$(pactl info | grep 'Default Source:')"
DEFAULT_SOURCE="${DEFAULT_SOURCE##*Default Source: }"

pactl load-module module-null-sink sink_name=VirtSink1 sink_properties="device.description=Virtual-Output"
pactl load-module module-null-sink sink_name=VirtSink2 sink_properties="device.description=Virtual-Mic"
pactl load-module module-loopback source="VirtSink1.monitor" sink="VirtSink2"
pactl load-module module-loopback source="VirtSink1.monitor" sink="@DEFAULT_SINK@"
pactl load-module module-loopback source="@DEFAULT_SOURCE@" sink="VirtSink2"


echo "Everything is set up. Now open pavucontrol (Pulse Audio Volume Control) and set all applications that you want to stream to the output device \"Virtual-Output\". Then suse the \"Virtual-Mic\" device in your call/stream."

