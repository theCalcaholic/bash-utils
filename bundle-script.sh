#!/usr/bin/env bash

DESCRIPTION="Bundles a script with it's dependencies (meant to be used for scripts from https://github.com/theCalcaholic/bash-utils)"

USAGE="bundle-script.sh input output

  input:  path to the original script
  output: path to save the bundled script at."

. "$(dirname "$BASH_SOURCE")/lib/parse_args.sh"
declare -a REQUIRED=("input" "output")
set_trap 1 2
parse_args __USAGE "$USAGE" __DESCRIPTION "$DESCRIPTION" "$@"

input_script="${NAMED_ARGS["input"]}"
output_script="${NAMED_ARGS["output"]}"

cat <(sed '/lib\/parse_args.sh/,$d' < "$input_script") \
  <(echo "") \
  <(echo "##### lib/parse_args.sh #####") \
  <(echo -n ". <(echo '") \
  <(cat "$(dirname "$0")/lib/parse_args.sh" | base64 -w 0) \
  <(echo "' | base64 -d)") \
  <(echo "#############################") \
  <(echo "") \
  <(sed '1,/lib\/parse_args.sh/d' < "$input_script") | tee "$output_script"

#cat "\\n\\n$replace\\n\\n" | sed -e "/\\/lib\\/parse_args.sh/s/^.*$/'\\&'/g" "$input_script"

