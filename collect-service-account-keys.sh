#!/usr/bin/env bash

#
# Lists all iam service accounts and their keys
#

USAGE="USAGE:
  collect-service-account-keys [OPTIONS]

  Options:
      -p, --project project_id Use the specified project instead of your gcloud default

Note: You need to be logged into gcloud (gcloud auth login) when executing this command!"

set -e

. "$(dirname $BASH_SOURCE)/lib/parse_args.sh"
set_trap 1 2
declare -a KEYWORDS=("-p" "--project")
parse_args __USAGE "$USAGE" "$@"

project_argument=""
if [[ -n "${KW_ARGS["-p"]}" ]] || [[ -n "${KW_ARGS["--project"]}" ]]
then
  project_argument="${KW_ARGS["-p"]}"
  project_argument="--project=${KW_ARGS["--project"]-"$project_argument"}"
fi

emails="$(gcloud iam service-accounts list $project_argument --sort-by=email --format=yaml | grep email | awk '{print $2}')"

while read -r line
do
	echo -n "$line:"
    gcloud iam service-accounts keys list --managed-by=user --iam-account="$line" 2> /dev/null \
        | grep -v KEY_ID \
        | awk '{printf "\n  -\n    id: %s\n    created: %s\n    expires: %s", $1,$2,$3}'
    [[ ${PIPESTATUS[1]} == 0 ]] || echo -n " []"
    echo ""
done < <(printf "%s\n" $emails)

