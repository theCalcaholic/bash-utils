#!/usr/bin/env bash

if [[ " $* " =~ .*(" -h "|" --help ").* ]]
then
  # TODO
  echo "DESCRIPTION"
  echo "USAGE"
  exit 0
fi


installed_pkgs="$(dpkg -l | grep '^ii' | awk '{print $2}')"
declare installation_candidates
for pkg in $@
do
  if [[ -z "$(echo "$installed_pkgs" | grep "^$pkg$")" ]]
  then
    installation_candidates+=("$pkg")
  fi
done

echo "apt-get install ${installation_candidates[@]}" \
&& apt-get install ${installation_candidates[@]} \
&& apt-mark auto ${installation_candidates[@]}

