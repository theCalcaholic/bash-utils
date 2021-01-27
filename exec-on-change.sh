#!/usr/bin/env bash

set -e

DESCRIPTION="Execute CMD whenever a file within DIR has been changed."
USAGE="exec-on-change.sh DIR CMD [OPTIONS]
  DIR: Path to watch for changes
  CMD: Command to execute

  OPTIONS:
    --help, -h: Show this message"

### ARGUMENT PARSING ###

. "$(dirname "$0")/lib/parse_args.sh"

parse_args __USAGE "$USAGE" __DESCRIPTION "$DESCRIPTION" "$@"
set_trap 1 2

if [[ ${#ARGS[@]} -ne 2 ]]
then
  echo "ERROR: inotify_exec expects exactly two positional argument! Got: ${ARGS[*]@Q}"
  print_usage
  exit 1
fi

WATCH_DIR="${ARGS[0]}"
CMD="${ARGS[1]}"

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

