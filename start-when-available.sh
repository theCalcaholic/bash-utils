#!/usr/bin/env bash

#
# Start given command as soon as a url can be reached
#

print_usage() {
    echo "Usage: start-when-available [--delay time] [--batch] url cmd"
}

expected=""
min_wait_time=5
url=''
cmd=''
batch_mode=0

for arg in "$@"
do
	if [ "$expected" == "wait" ]
	then
		min_wait_time="$arg"
    fi

    if [ ! -z "$expected" ]
    then
        expected=""
        continue
    elif [ "$arg" == "--batch" ] || [ "$arg" == "-b" ]
	then
		batch_mode=1
	elif [ "$arg" == "--wait" ] || [ "$arg" == "-w" ]
	then
		expected='wait'
	elif [ "$arg" == "--help" ] || [ "$arg" == "-h" ]
    then
        print_usage
		exit 0
    elif [ -z "$url" ]
    then
        url="$arg"
    elif [ -z "$cmd" ]
    then
        cmd="$arg"
    else
        echo "ERROR: start-when-available expects exactly two positional argument! Got: '$@'"
        print_usage
        exit 1
    fi

done

if [[ "$batch_mode" == 1 ]]
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
