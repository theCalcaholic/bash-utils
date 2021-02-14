#!/usr/bin/env bash

DESCRIPTION="Compare two directory trees"
USAGE="treediff.sh directory-1 directory-2"

. "$(dirname $BASH_SOURCE)/lib/parse_args.sh"
REQUIRED=("directory-1" "directory-2")
parse_args __USAGE "$USAGE" __DESCRIPTION "$DESCRIPTION" "$@"

diff <( tree -i "${NAMED_ARGS['directory-1']}" ) <( tree -i "${NAMED_ARGS['directory-2']}" )

