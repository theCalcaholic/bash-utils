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

### ARGUMENT PARSING ###

. "$(dirname "$BASH_SOURCE")/lib/parse_args.sh"

declare -a KEYWORDS=("--delimiter" "-d" "-s;bool" "--skip-header;bool")
declare -a REQUIRED=("columns" "file")
set_trap 1 2
parse_args __DESCRIPTION "$DESCRIPTION" __USAGE "$USAGE" "$@"

skip_header="${KW_ARGS["-s"]-false}"
skip_header="${KW_ARGS["--skip-header"]-${skip_header}}"

IFS=',' read -r -a columns <<<"${NAMED_ARGS["columns"]}"
echo "columns: ${columns[@]}"
file="${NAMED_ARGS["file"]}"
delim="${KW_ARGS["-d"]-"|"}"
delim="${KW_ARGS["--delimiter"]-"$delim"}"

######

exec 5< "$file"

while read line <&5
do
    if [ "$skip_header" == "true" ]
    then
        echo "$line"
        skip_header=false
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

