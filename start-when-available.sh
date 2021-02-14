#!/usr/bin/env bash

DESCRIPTION="Start given command as soon as a url can be reached"
USAGE="Usage: start-when-available [OPTIONS][--delay time] [--batch] [--help|-h] url cmd

  url
    The url that needs to be available before executing the command
  command
    The command to be executed

  Options:
    -d, --delay time A minimum delay (in seconds) after which the command can be executed
    -b, --batch      Use batch mode for executing the command (can help with system resource 
                     consumption)"

. "$(dirname $BASH_SOURCE)/lib/parse_args.sh"
REQUIRED=("url" "command")
KEYWORDS=("-d;int" "--delay;int" "-b;bool" "--batch;bool")
parse_args __USAGE "$USAGE" __DESCRIPTION "$DESCRIPTION" "$@"
set_trap 1 2

min_wait_time="${KW_ARGS['-d']-5}"
min_wait_time="${KW_ARGS['--delay']-$min_wait_time}"
url="${NAMED_ARGS['url']}"
cmd="${NAMED_ARGS['command']}"
batch_mode="${KW_ARGS['-b']-false}"
batch_mode="${KW_ARGS['--batch']-$batch_mode}"


if [[ "$batch_mode" == "true" ]]
then
    [[ -z "$(command -v batch)" ]] && {
        echo "ERROR: 'batch' command not found! Is the at package installed?"
        exit 1
    }
    echo "cmd: $cmd";
    cmd="${cmd//\'/\\\'}"
    cmd="${cmd//\"/\\\"}"
    echo "cmd escaped: $cmd"

    batch_cmd="export DISPLAY=$DISPLAY; \"$0\" \"$url\" \"$cmd\" &"
    msg="Executing on low system load: \"$batch_cmd\"..."
    echo "$msg"
    [[ -z "$(command -v notify-send)" ]] || notify-send "$msg"

    echo "\"$batch_cmd\"" | cat
    set -x
    echo "$batch_cmd" | batch
    set +x
    exit 0
fi


sleep "$min_wait_time"

while ! curl "$url" &> /dev/null ;
do
    sleep 1
done

bash -c "$cmd"
