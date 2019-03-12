#!/usr/bin/env bash

set -e

print_usage() {
    echo "USAGE:"
    echo "  anonymize-cols [OPTIONS] columns table"
    echo "  columns:"
    echo "      A comma separated list of column ids to anonymize"
    echo "  table:"
    echo "      The table to anonymize in csv format"
    echo ""
    echo "  Options:"
    echo "      -d, --delimiter Delimiter to split table by"
    echo "      -s, --skip-header Ignore (Don't change) first row table"
}

trap print_usage 1 2

expected=""
delim=""
columns=""
payload=""
skip_header=0

for arg in "$@"
do
	if [ "$expected" == "delim" ]
	then
		delim="$arg"
	elif [ "$arg" == "--delimiter" ] || [ "$arg" == "-d" ]
	then
		expected='delim'
	elif [ "$arg" == "--skip-header" ] || [ "$arg" == "-s" ]
	then
		skip_header=1
	elif [ "$arg" == "--help" ] || [ "$arg" == "-h" ]
    then
        print_usage
		exit 0
    elif [ -z "$columns" ]
    then
        IFS_BK="$IFS"
        IFS=","
        read -ra columns <<< "$arg"
        IFS="$IFS_BK"
    elif [ -z "$payload" ]
    then
        payload="$arg"
    else
        echo "ERROR: anonymize-cols expects exactly two positional argument! Got: '${arg:0:16}'"
        print_usage
        exit 1
    fi
    expected=""
done

if [ -z "$payload" ]
then
    echo "ERROR: Missing arguments!"
    print_usage
    exit 1
fi

if [ "$skip_header" == "1" ]
then
    echo "$payload" | head -n 1
    payload="$(echo "$payload" | tail -n+2)"
fi

for column in ${columns[@]}
do
    payload="$(
        echo "$payload" \
        | awk -F "|" '{
            OFS="|";
            {
                gsub(/[0-9]/, "0", $'$column')
                gsub(/[a-z]/,"a", $'$column')
                gsub(/[A-Z]/,"A", $'$column')
            }
            print
        }'
    )"
done

echo "$payload"
