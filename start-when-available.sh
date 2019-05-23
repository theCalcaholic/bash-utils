#!/usr/bin/env bash

#
# Start given command as soon as a url can be reached
#

MINIMUM_WAIT_TIME=${3:-5}
URL=${1?}
CMD=${2?}

sleep "$MINIMUM_WAIT_TIME"

while ! curl "$URL" &> /dev/null ;
do
    sleep 1
done

bash -c "$CMD"
