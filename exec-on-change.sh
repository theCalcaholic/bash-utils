#!/usr/bin/env bash

set -e

print_help() {
    echo "Execute CMD whenever a file within DIR has been changed.
USAGE: inotify_exec.sh DIR CMD [OPTIONS]
  DIR: Path to watch for changes
  CMD: Command to execute

  OPTIONS:
    --help, -h: Show this message"
}

### ARGUMENT PARSING ###

. "$(dirname "$0")/lib/parse_args.sh"

#declare -a KEYWORDS=("--delimiter" "-d")
parse_args "$@"

if [[ " ${ARGS[*]} " =~ .*(" --help "|" -h ").* ]]
then
  print_usage
  exit 0
fi

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

