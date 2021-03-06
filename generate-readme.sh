#!/usr/bin/env bash

set -e
. "$(dirname $BASH_SOURCE)/lib/parse_args.sh"
set_trap 1 2
parse_args __USAGE "generate-readme.sh" "$@"

cat "$(dirname $BASH_SOURCE)/README_HEAD.md"

echo "## Scripts"
echo ""

for script in "$(dirname $0)/"*.sh;
do
  scriptname="$(basename "$script")"
  echo "- [$scriptname](#${scriptname//\./})"
done

echo "---"

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
