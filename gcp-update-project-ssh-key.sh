#!/usr/bin/env bash

. "$(dirname "$BASH_SOURCE")/lib/parse_args.sh"

KEYWORDS=("--non-interactive;bool")
REQUIRED=("command" "project-id" "user" "ssh-public-key")
parse_args __DESCRIPTION "Replaces or updates the ssh key for a specific user in the metadata of a Google Project" \
    __USAGE "gcp-update-project-ssh-key.sh [OPTIONS] command project-id user ssh-public-key

  command             The command to perform. One of add (adds the key if there wasn't any
                      configured for the given user yet), replace (replaces any old key of the user)
  project-id          The project containing the metadata to edit
  user                The ssh user name of the user of which to replace the public key
  ssh-public-key      The public key to replace the old one with

  Options:
    --non-interactive Don't ask for confirmation before making any changes (potentially dangerous!)
    --help            Show this help message" "$@"

project="${NAMED_ARGS["project-id"]}"
replace_user="${NAMED_ARGS["user"]}"
new_line="$replace_user:${NAMED_ARGS["ssh-public-key"]} $replace_user"

set -e

ssh_keys_old="$(mktemp)"
ssh_keys_new="$(mktemp)"
echo "Saving ssh keys to $ssh_keys_old"

trap "[[ \$? -eq 0 ]] || { echo ""; print_usage; }; rm $ssh_keys_old $ssh_keys_new;" EXIT

cmd="${NAMED_ARGS["command"]}"
[[ " add replace " =~ .*" $cmd ".* ]] || {
  echo""
  echo "ERROR: Invalid command '$cmd'"
  exit 1
}

gcloud compute project-info describe \
    --project="$project" \
    --flatten="commonInstanceMetadata.items" \
    --format="json(commonInstanceMetadata.items.key,commonInstanceMetadata.items.value)" \
    | jq -r \
    '.[] | select(.commonInstanceMetadata.items.key=="ssh-keys") | .commonInstanceMetadata.items.value' > "$ssh_keys_old"

#echo "$ssh_keys"
#echo "$ssh_keys" | grep "${2?ERROR: Missing parameter: 'user'}"
user_exists=false
while read -r line; 
do
    #echo "LINE: $line"
    user="${line/%:*/}"
    #echo "user: $user"
    if [[ "${user}" == "${replace_user}" ]]
    then
        user_exists=true
    fi
    if [[ "${user}" == "${replace_user}" ]] && [[ "${cmd}" == "replace" ]]
    then
        echo ""
        #echo "user: ${line/%:*/}"
        #key="${line/%\{*/}"
        #echo "key: ${key/#*:/}"
        echo "Replacing:"
        echo "  user: $user"
        echo "  line: $line"
        echo "with:"
        echo "  user: $replace_user"
        echo "  line: $new_line"
        echo "$new_line" >> "$ssh_keys_new"
        echo ""
    else
        echo "$line" >> "$ssh_keys_new"
    fi
    #echo ""
done <"$ssh_keys_old"

if [[ "$user_exists" == "false" ]] && [[ "${cmd}" == "add" ]]
then
  echo ""
  echo "Adding new user:"
  echo "  user: $replace_user"
  echo "  line: $new_line"
  echo "$new_line" >> "$ssh_keys_new"
fi

if ! cmp "$ssh_keys_old" "$ssh_keys_new" > /dev/null
then

  echo "New ssh pubkeys file:"
  echo ""
  cat "$ssh_keys_new" | grep -e '^' -e '^.*:' --color
  echo ""

  if [[ "$KW_ARGS['--non-interactive']" != 'true' ]]
  then
    echo "Continue? (y/N)"
    read choice

    [[ "$choice" =~ ^(y|Y)$ ]] || { echo "User abort."; exit 0; }
  fi

  gcloud compute project-info add-metadata --project="$project" --verbosity debug --metadata-from-file ssh-keys="$ssh_keys_new"
else
  echo "Nothing to do!"
fi
echo ""

