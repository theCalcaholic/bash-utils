#!/usr/bin/env bash

set -e

declare -A USAGE
USAGE[PATH]="The path to analyze"
DESCRIPTION="Lists sorted, human-readable sizes of subdirectories"
. "$(dirname $BASH_SOURCE)/lib/parse_args_v2.sh"
parse_args "$@"

path="${ARGS[0]:-$(pwd)}"


#path="${1:-$(pwd)}"
count="$(ls -lA "$path" | wc -l)"

du -ahd 1 "$path" | pv -clN du-tool -s "$count" -F "%N: %t %p [%b/$count]" | sort -h

