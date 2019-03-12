#!/usr/bin/env bash

#
# Start given command as soon as a url can be reached
#

URL=${1?}
CMD=${2?}

while ! curl "$URL" &> /dev/null ;
do
    sleep 1
done

bash -c "$CMD"
