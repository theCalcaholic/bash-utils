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
    echo "      -o format Change output format. Can be one of 'yaml', 'spaced', 'spaced-40', 'spaced-80' and 'spaced-120'"
    echo ""
    echo "Note: You need to be logged into gcloud (gcloud auth login) when executing this command!"
}

spaced_format='{ printf "%s%-SPACE_WIDTHs %s\n", "    - ", $1, $2 }'
yaml_format='{ printf "%s\n%s%s\"\n%s\"%s\n", "    -", "      member: ", $1, "      role: ", $2 }'
format='{ print "    - ", $1, $2 }'
project_arg=""

for arg in $@
do
    if [[ $expected == "project" ]]
    then
        project_arg="-p $arg"
    elif [[ $expected == "output" ]]
    then
        if [[ $arg == "yaml" ]]
        then
            format="$yaml_format"
        elif [[ $arg == "spaced" ]] || [[ $arg == "spaced-40" ]]
        then
            format="$( echo "$spaced_format" | sed 's/SPACE_WIDTH/39/' )"
        elif [[ $arg == "spaced-80" ]]
        then
            format="$( echo "$spaced_format" | sed 's/SPACE_WIDTH/79/' )"
        elif [[ $arg == "spaced-120" ]]
        then
            format="$( echo "$spaced_format" | sed 's/SPACE_WIDTH/119/' )"
        else
            echo "ERROR: Invalid output format '$arg'!"
            echo ""
            print_usage
            exit 1
        fi
    fi

    if [[ $arg == "-p" ]]
    then
        expected="project"
    elif [[ $arg == "--help" ]]
    then
        print_usage
        exit 0
    elif [[ $arg == "--output" ]] || [[ $arg == "-o" ]]
    then
        expected="output"
    fi
done

for bucket in $(gsutil ls $project_arg)
do
    bucket_iam="$(gsutil iam get $bucket)"
    echo "$(basename $bucket):"
    echo "$bucket_iam" \
        | jq '.bindings[] | "\(.members[]) \(.role)"' \
        | awk "$format"
done

