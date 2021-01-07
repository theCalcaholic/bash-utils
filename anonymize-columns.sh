#!/usr/bin/env bash

export DESCRIPTION="Replaces specific columns in a csv table with generic data in the same format
by mapping '0-9' -> '0', 'a-z' -> 'a' and 'A-Z' -> 'A'"
export USAGE="anonymize-columns [OPTIONS] columns file
columns:
  A comma separated list of column ids to anonymize
  file:
  The csv file to anonymize

  Options:
    -d, --delimiter <delimiter> Delimiter to split table by
    -s, --skip-header Ignore (Don't change) first row table"

set -e

print_usage() {
    echo "USAGE:"
    echo "  ${USAGE//
/
  }"
}

print_description() {
    echo "DESCRIPTION:
  ${DESCRIPTION//
/
  }"
}

trap "print_description; print_usage" 1 2

### ARGUMENT PARSING ###

. "$(dirname "$0")/lib/parse_args.sh"

declare -a KEYWORDS=("--delimiter" "-d")
parse_args "$@"

if [[ " ${ARGS[*]} " =~ .*(" --help "|" -h ").* ]]
then
  print_description
  print_usage
  exit 0
fi

skip_header=0
pos_arg_count=2
if [[ " ${ARGS[*]} " =~ .*(" --skip-header "|" -s ").* ]]
then
  skip_header=1
  pos_arg_count=3
fi

if [[ ${#ARGS[@]} -ne $pos_arg_count ]]
then
  echo "ERROR: anonymize-cols expects exactly two positional argument! Got: ${ARGS[*]@Q}"
  print_usage
  exit 1
fi


columns="${ARGS[0]}"
file="${ARGS[1]}"
delim="${KW_ARGS["-d"]-"|"}"
delim="${KW_ARGS["--delimiter"]-"$delim"}"

######

exec 5< "$file"

while read line <&5
do
    if [ "$skip_header" == "1" ]
    then
        echo "$line"
        skip_header=0
        continue
    fi

    for column in ${columns[@]}
    do
        line="$(
            echo "$line" \
            | awk -F "$delim" '{
                OFS="'$delim'";
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

