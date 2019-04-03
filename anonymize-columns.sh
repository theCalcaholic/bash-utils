#!/usr/bin/env bash

# 
# Replaces specific columns in a csv table with generic data in the same format
# by mapping '0-9' -> '0', 'a-z' -> 'a' and 'A-Z' -> 'A'
#

set -e

print_usage() {
    echo "USAGE:"
    echo "  anonymize-columns [OPTIONS] columns file"
    echo "  columns:"
    echo "      A comma separated list of column ids to anonymize"
    echo "  file:"
    echo "      The csv file to anonymize"
    echo ""
    echo "  Options:"
    echo "      -d, --delimiter <delimiter> Delimiter to split table by"
    echo "      -s, --skip-header Ignore (Don't change) first row table"
}

trap print_usage 1 2

expected=""
delim="|"
columns=""
file=""
skip_header=0
batch_size=20

for arg in "$@"
do
	if [ "$expected" == "delim" ]
	then
		delim="$arg"
    fi

    if [ ! -z "$expected" ]
    then
        expected=""
        continue
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
    elif [ -z "$file" ]
    then
        file="$arg"
    else
        echo "ERROR: anonymize-cols expects exactly two positional argument! Got: '${columns:0:16}' '${file:0:16}' '${arg:0:16}'"
        print_usage
        exit 1
    fi
done


#        for line in {1..16027..20}; do anonymize-columns -s -d "|" 3,4 "$(sed -n "$line,+19p" ~/Downloads/ec1200_customermasterdata_v3_20190402.tar.gz)"; done; } | tee ~/Downloads/ec1200_customermasterdata_v3_20190402_cleared.csv

if [ -z "$file" ]
then
    echo "ERROR: Missing arguments!"
    print_usage
    exit 1
fi

#if [ "$skip_header" == "1" ]
#then
#    echo "$payload" | head -n 1
#    payload="$(echo "$payload" | tail -n+2)"
#fi

exec 5< "$file"

while read line <&5
do
    if [ "$skip_header" == "1" ]
    then
        skip_header=0
        continue
    fi

    for column in ${columns[@]}
    do
        line="$(
            echo "$line" \
            | awk -F "$delim" '{
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

    echo "$line"
done

