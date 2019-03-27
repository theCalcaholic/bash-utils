#!/usr/bin/env bash

#
# Lists all iam service accounts and their keys
#

print_usage() {
    echo "USAGE:"
    echo "  collect-service-account-keys [OPTIONS]"
    echo ""
    echo "  Options:"
    echo "      -p, --project project_id Use the specified project instead of your gcloud default"
    echo ""
    echo "Note: You need to be logged into gcloud (gcloud auth login) when executing this command!"
}

set -e

project_argument=""
expected=""

for arg in $@
do
    if [[ $expected == "project" ]]
    then
        project_argument="--project=$arg"
    fi

    if [[ ! -z $expected ]]
    then
        expected=""
        continue
    fi

    if [[ $arg == "-p" ]] || [[ $arg == "--project" ]]
    then
        expected="project"
    elif [[ $arg == "--help" ]]
    then
        print_usage
        exit 0
    fi
done

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
