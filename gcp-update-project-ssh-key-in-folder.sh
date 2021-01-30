#!/usr/bin/env bash

USAGE="gcp-update-project-ssh-key-in-folder.sh [OPTIONS] command folder user ssh-public-key

  command:        'add' if the user/public key should be added to projects where it doesn't exist yet
                  or 'replace' if existing ssh-public-keys for the user should be replaced
  folder:         The id of the gcp folder which contains all projects that the ssh public key should
                  be rolled out to
  user:           The ssh user
  ssh-public-key: The ssh public key

  Options:
    --blacklist \"project1 [project2 [...]]\" A space separated list of project ids to not rollout any ssh public keys to
    --interactive true|false Ask for confirmation before making any changes (disabling is potentially dangerous!)
"

. "$(dirname "$0")/lib/parse_args.sh"

set_trap 1 2

KEYWORDS=("--blacklist --interactive")
parse_args __USAGE "$USAGE" "$@"

projects_blacklist="${KW_ARGS['--blacklist']:-}"
interactive="${KW_ARGS['--interactive']:-true}"

cmd="${ARGS[0]?ERROR: Missing parameter 'command'}"
ARGS=("${ARGS[@]:1}")
folder="${ARGS[0]?ERROR: Missing parameter 'folder'}"
ARGS=("${ARGS[@]:1}")
user="${ARGS[0]?ERROR: Missing parameter 'user'}"
ARGS=("${ARGS[@]:1}")
ssh_public_key="${ARGS[0]?ERROR: Missing parameter 'ssh-public-key'}"
ARGS=("${ARGS[@]:1}")


for project in $(/opt/bash-utils/gcp-list-projects-in-folder.sh "$folder" "${ARGS[@]}")
do 
  if ! [[ " $projects_blacklist " =~ .*" $project ".* ]]; 
  then 
    echo -e "\033[0;36m${project}\033[0m"
    /opt/bash-utils/gcp-update-project-ssh-key.sh --interactive "$interactive" "$cmd" "$project" "$user" "$ssh_public_key"; 
  fi
done

