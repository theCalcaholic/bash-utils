#!/usr/bin/env bash

set -e

DESCRIPTION="Execute CMD whenever a file within DIR has been changed."
USAGE="exec-on-change.sh directory command [OPTIONS]
  directory: Path to watch for changes
  command: Command to execute

  OPTIONS:
    --help, -h: Show this message"

### ARGUMENT PARSING ###

. "$(dirname "$BASH_SOURCE")/lib/parse_args.sh"
REQUIRED=("directory" "command")
parse_args __USAGE "$USAGE" __DESCRIPTION "$DESCRIPTION" "$@"
set_trap 1 2

WATCH_DIR="${NAMED_ARGS["directory"]}"
CMD="${NAMED_ARGS["command"]}"

######

while true
do
    inotifywait -r -e modify "${WATCH_DIR?}" \
        && sleep 1 \
        && {
        echo "Executing '$CMD'..."
        bash -c "$CMD" 
        } || exit 0
done

