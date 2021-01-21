#!/usr/bin/env bash

. "$(dirname "$0")/lib/parse_args.sh"

parse_args __DESCRIPTION "Replaces the ssh key for a specific user in the metadata of a Google Project" \
    __USAGE "gcp-replace-project-ssh-key.sh project-id user ssh-public-key

  project-id:     The project containing the metadata to edit
  user:           The ssh user name of the user of which to replace the public key
  ssh-public-key: The public key to replace the old one with"

ssh_keys_old="$(mktemp)"
ssh_keys_new="$(mktemp)"
echo "Saving ssh keys to $ssh_keys_old"
echo ""

trap "[[ \$? -eq 0 ]] || { echo ""; print_usage; }; rm $ssh_keys_old $ssh_keys_new;" EXIT

gcloud compute project-info describe \
    --project="${1?ERROR: Missing parameter: 'project'}" \
    --flatten="commonInstanceMetadata.items" \
    --format="json(commonInstanceMetadata.items.key,commonInstanceMetadata.items.value)" \
    | jq -r \
    '.[] | select(.commonInstanceMetadata.items.key=="ssh-keys") | .commonInstanceMetadata.items.value' > "$ssh_keys_old"

#echo "$ssh_keys"
#echo "$ssh_keys" | grep "${2?ERROR: Missing parameter: 'user'}"

replace_user="${2?ERROR: Missing parameter: 'user'}"
new_line="$replace_user:${3?ERROR: Missing parameter: 'ssh-public-key'} $replace_user"

while read -r line; 
do
    #echo "LINE: $line"
    user="${line/%:*/}"
    #echo "user: $user"
    if [[ "${user}" == "${replace_user}" ]]
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

echo "New ssh pubkeys file:"
echo ""
cat "$ssh_keys_new"
echo ""
echo "Continue? (y/N)"
read choice

[[ "$choice" =~ ^(y|Y)$ ]] || exit 0

gcloud compute project-info add-metadata --project="${1?}" --verbosity debug --metadata-from-file ssh-keys="$ssh_keys_new"

