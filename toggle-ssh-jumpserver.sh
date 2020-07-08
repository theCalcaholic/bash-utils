#!/usr/bin/env bash

USER="${1?}"
JS="${2?}"
STATE="${3?}"
LOGFILE="/var/log/jumpserver_toggle.log"

USER_HOME="$(getent passwd "$USER" | cut -d: -f6)"

{
if [[ ! -f "$USER_HOME/.ssh/config" ]]
then
  echo "No ssh config found for user $USER!"
  exit 1
fi

if [[ "$STATE" == "enable" ]]
then
  echo -n 'Enable '
  sed -i "s/#ProxyJump ${JS}/ProxyJump ${JS}/g" $USER_HOME/.ssh/config
else
  echo -n 'Disable '
  sed -i "s/ ProxyJump ${JS}/ #ProxyJump ${JS}/g" $USER_HOME/.ssh/config
fi

echo "jump server $JS for user $USER"
} | tee -a "$LOGFILE"
