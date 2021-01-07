#!/usr/bin/env bash

DESCRIPTION="Bundles a script with it's dependencies (meant to be used for scripts from https://github.com/theCalcaholic/bash-utils)"

USAGE="bundle-script.sh input output

  input:  path to the original script
  output: path to save the bundled script at."

. "$(dirname "$0")/lib/parse_args.sh"
set_trap 1 2
parse_args __USAGE "$USAGE" __DESCRIPTION "$DESCRIPTION" "$@"

input_script="${ARGS[0]?}"
output_script="${ARGS[0]?}"

cat <(sed '/lib\/parse_args.sh/,$d' < "$input_script") \
  <(echo "") \
  <(echo "####################") \
  "$(dirname "$0")/lib/parse_args.sh" \
  <(echo "####################") \
  <(echo "") \
  <(sed '1,/lib\/parse_args.sh/d' < "$input_script") | tee "$output_script"

#cat "\\n\\n$replace\\n\\n" | sed -e "/\\/lib\\/parse_args.sh/s/^.*$/'\\&'/g" "$input_script"

