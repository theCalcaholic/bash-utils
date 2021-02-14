#!/usr/bin/env bash

set -e
. "$(dirname $BASH_SOURCE)/lib/parse_args.sh"
set_trap 1 2
parse_args __USAGE "generate-readme.sh" "$@"

echo "# A collection of scripts I have written over the years"

for script in "$(dirname $BASH_SOURCE)/"*.sh;
do 
  echo "### $(basename "$script")"
  echo ""
  echo '```yaml'

  # Exclude scripts not yet using my argument parser
  grep 'parse_args' "$script" > /dev/null || { echo '```'; continue; }

  "$script" -h
  echo '```'
  echo ""
done
