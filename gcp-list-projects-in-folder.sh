#!/usr/bin/env bash

. "$(dirname "$0")/lib/parse_args.sh"
set_trap 1 2

parse_args __DESCRIPTION "Lists all projects contained in a GCP folder or its subfolders" \
    __USAGE "gcp-list-projects-in-folder.sh folder_id

  folder_id: The id of the root folder that should be searched" "$@"

folder_id="${1?}"
shift

items=("folders/$folder_id")
debug=false
i=0

echo "Searching folders recursively..." >&2

while [[ $(( "$i" < "${#items[@]}" )) -eq 1 ]];
do
    echo "Searching: ${items[i]}" >&2
    if [[ "${items[i]}" =~ "folders/".* ]]
    then
        $debug && echo "current (name): $(gcloud resource-manager folders  describe "${items[i]/#folders\//}" --format="get(displayName)")" >&2
        $debug && echo "items+=(\$(gcloud resource-manager folders list --folder \"${items[i]/#folders\//}\" --format='get(NAME)' \"$@\" 2>/dev/null | xargs))" >&2
        items+=($(gcloud resource-manager folders list --folder "${items[i]/#folders\//}" --format='get(NAME)' "$@" 2>/dev/null | xargs))
    fi
    i="$((i+1))"
done

echo "" >&2
echo "Projects:" >&2
echo "=========" >&2
for folder in "${items[@]}"
do
    gcloud projects list --filter="parent.id=${folder/#folders\//}" --format="get(PROJECT_ID)"
done

