#!/usr/bin/env bash

USAGE="toggle-ssh-jumpserver.sh command user jump-server-name

  command
    'enable' if the jump server should be enabled, else 'disable'
  user
    The user whose ssh config should be edited
  jump-server
    The name of the jump server to use. Needs to correspond to an entry in the user's ssh config"

. "$(dirname $BASH_SOURCE)/lib/parse_args.sh"
REQUIRED=("command" "user" "jump-server")
parse_args __USAGE "$USAGE" "$@"
set_trap 1 2

USER="${NAMED_ARGS['user']}"
JS="${NAMED_ARGS['jump-server']}"
STATE="${NAMED_ARGS['command']}"
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

