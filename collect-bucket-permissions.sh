#!/usr/bin/env bash

#
# Lists all buckets in your GCP project and their iam bindings
#


set -e

print_usage() {
    echo "USAGE:"
    echo "  collect-bucket-permissions [OPTIONS]"
    echo ""
    echo "  Options:"
    echo "      -p project_id Use the specified project instead of your gcloud default"
    echo ""
    echo "Note: You need to be logged into gcloud (gcloud auth login) when executing this command!"
}

trap print_usage 1 2

project_arg=""

for arg in $@
do
    if [[ $expected == "project" ]]
    then
        project_arg="-p $arg"
    fi

    if [[ $arg == "-p" ]]
    then
        expected="project"
    elif [[ $arg == "--help" ]]
    then
        print_usage
        exit 0
    fi
done

for bucket in $(gsutil ls $project_arg)
do
    bucket_iam="$(gsutil iam get $bucket)"
    echo "$(basename $bucket):"
    echo "$bucket_iam" | jq '.bindings[] | "\(.members[]) \(.role)"' | awk '{ print "    - " $0 }' 
done

