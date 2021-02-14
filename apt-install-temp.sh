#!/usr/bin/env bash

. "$(dirname "$BASH_SOURCE")/lib/parse_args.sh"
declare -a REQUIRED=("package")
parse_args __DESCRIPTION "Install apt packages and marks them as automatically installed (to allow easy removal via apt autoremove)" \
  __USAGE "apt-install-temp.sh package [package [...]]" "$@"


installed_pkgs="$(dpkg -l | grep '^ii' | awk '{print $2}')"
declare installation_candidates
for pkg in "${NAMED_ARGS["package"]}" "${ARGS[@]}"
do
  if [[ -z "$(echo "$installed_pkgs" | grep "^$pkg$")" ]]
  then
    installation_candidates+=("$pkg")
  fi
done

echo "apt-get install ${installation_candidates[@]}" \
  && apt-get install ${installation_candidates[@]} \
  && apt-mark auto ${installation_candidates[@]}

