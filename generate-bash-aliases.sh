#!/usr/bin/env bash

USAGE="generate-bash-aliases.sh > bashrc

  Options:
    --output, -o path File to write to"

set -e
. "$(dirname $BASH_SOURCE)/lib/parse_args.sh"
KEYWORDS=("-o" "--output")
parse_args __USAGE "$USAGE" "$@"

output_file="${KW_ARGS['--output']-${KW_ARGS['-o']}}"
output_cmd="cat"

if [[ -n "$output_file" ]]
then
    output_cmd="tee -a $output_file"
    echo "" > "$output_file"
fi

for script in "$(dirname $BASH_SOURCE)"/*.sh
do
  echo "alias $(basename -s '.sh' "$script")='$(realpath "$script")'" | $output_cmd
done

