#!/usr/bin/env bash

. "$(dirname "$0")/lib/parse_args.sh"


parse_args __DESCRIPTION "Replaces the ssh key for a specific user in the metadata of a Google Project" \
    __USAGE "gcp-replace-project-ssh-key.sh command project-id user ssh-public-key

  command:        The command to perform. One of add (adds the key if there wasn't any
                  configured for the given user yet), replace (replaces any old key of the user)
  project-id:     The project containing the metadata to edit
  user:           The ssh user name of the user of which to replace the public key
  ssh-public-key: The public key to replace the old one with" "$@"

ssh_keys_old="$(mktemp)"
ssh_keys_new="$(mktemp)"
echo "Saving ssh keys to $ssh_keys_old"

trap "[[ \$? -eq 0 ]] || { echo ""; print_usage; }; rm $ssh_keys_old $ssh_keys_new;" EXIT

cmd="${ARGS[0]?ERROR: Missing parameter: 'command'}"
[[ " add replace " =~ .*" $cmd ".* ]] || {
  echo""
  echo "ERROR: Invalid command '$cmd'"
  exit 1
}
project="${ARGS[1]?ERROR: Missing parameter: 'project'}"
replace_user="${ARGS[2]?ERROR: Missing parameter: 'user'}"
new_line="$replace_user:${ARGS[3]?ERROR: Missing parameter: 'ssh-public-key'} $replace_user"

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

if ! cmp "$ssh_keys_old" "$ssh_keys_new"
then

  echo "New ssh pubkeys file:"
  echo ""
  cat "$ssh_keys_new" | grep -e '^' -e '^.*:' --color
  echo ""
  echo "Continue? (y/N)"
  read choice

  [[ "$choice" =~ ^(y|Y)$ ]] || { echo "User abort."; exit 0; }

  gcloud compute project-info add-metadata --project="$project" --verbosity debug --metadata-from-file ssh-keys="$ssh_keys_new"
else
  echo "Nothing to do!"
fi
echo ""

