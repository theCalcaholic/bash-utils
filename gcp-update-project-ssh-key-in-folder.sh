#!/usr/bin/env bash

USAGE="gcp-update-project-ssh-key-in-folder.sh [OPTIONS] command folder user ssh-public-key

  command         'add' if the user/public key should be added to projects where it doesn't exist yet
                  or 'replace' if existing ssh-public-keys for the user should be replaced
  folder          The id of the gcp folder which contains all projects that the ssh public key should
                  be rolled out to
  user            The ssh user
  ssh-public-key  The ssh public key

  Options:
    --blacklist \"project1 [project2 [...]]\" A space separated list of project ids to not rollout any ssh public keys to
    --non-interactive Ask for confirmation before making any changes (disabling is potentially dangerous!)
"

. "$(dirname "$BASH_SOURCE")/lib/parse_args.sh"

set_trap 1 2

KEYWORDS=("--blacklist --non-interactive;bool")
REQUIRED=("command" "folder" "user" "ssh-public-key")
parse_args __USAGE "$USAGE" "$@"

projects_blacklist="${KW_ARGS['--blacklist']:-}"

cmd="${NAMED_ARGS["command"]}"
folder="${NAMED_ARGS["folder"]}"
user="${NAMED_ARGS["user"]}"
ssh_public_key="${NAMED_ARGS["ssh-public-key"]}"


for project in $(/opt/bash-utils/gcp-list-projects-in-folder.sh "$folder" "${ARGS[@]}")
do 
  if ! [[ " $projects_blacklist " =~ .*" $project ".* ]]; 
  then 
    echo -e "\033[0;36m${project}\033[0m"
    cmd_args=("$cmd" "$project" "$user" "$ssh_public_key")
    if [[ "${KW_ARGS['--non-interactive']}" == 'true' ]] 
    then
      cmd_args+=('--non-interactive')
    fi
    /opt/bash-utils/gcp-update-project-ssh-key.sh "${cmd_args[@]}"
  fi
done

