#!/usr/bin/env bash

#
# Lists all buckets in your GCP project and their iam bindings
#


set -e

USAGE="USAGE:
  collect-bucket-permissions [OPTIONS]

  Options:
      -p, --project project_id Use the specified project instead of your gcloud default
      -o, --output format Change output format. Can be one of 'yaml', 'spaced', 'spaced-40', 'spaced-80' and 'spaced-120'
      --sa-project For service accounts also print the project which contains it (given the permissions)

Note: You need to be logged into gcloud (gcloud auth login) when executing this command!"

. "$(dirname "$0")/lib/parse_args.sh"
declare -a KEYWORDS=("-p" "--project" "-o" "--output" "--sa-project")
set_trap 1 2
parse_args __DESCRIPTION "" __USAGE "$USAGE" "$@"


spaced_format='{ printf "%s%-SPACE_WIDTHs %s\n", "    - ", $1, $2 }'
yaml_format='{ printf "%s\n%s%s\"\n%s\"%s\n", "    -", "      member: ", $1, "      role: ", $2 }'
yaml_format_with_pid='{ printf "%s\n%s%s\"\n%s\"%s\n%s\"%s\"\n", "    -", "      member: ", $1, "      role: ", $2, "      project: ", $3 }'
format='{ print "    - ", $1, $2 }'

show_sa_projects=0
if [[ " ${ARGS[*]} " =~ .*"--sa-project".* ]]
then
  show_sa_projects=1
fi

project_arg=""
if [[ -n "${KW_ARGS["-p"-""]}" ]] || [[ -n "${KW_ARGS["--project"]}" ]]
then
  project_arg="${KW_ARGS["-p"]}"
  project_arg="-p ${KW_ARGS["--project"]-"$project_arg"}"
fi


format_name="${KW_ARGS["-o"]-"default"}"
format_name="${KW_ARGS["--output"]-"$format_name"}"
if [[ "$format_name" != "default" ]]
then

  if [[ $format_name == "yaml" ]]
  then
      format="$yaml_format"
  elif [[ $format_name == "spaced" ]] || [[ $format_name == "spaced-40" ]]
  then
      format="$( echo "$spaced_format" | sed 's/SPACE_WIDTH/39/' )"
  elif [[ $format_name == "spaced-80" ]]
  then
      format="$( echo "$spaced_format" | sed 's/SPACE_WIDTH/79/' )"
  elif [[ $format_name == "spaced-120" ]]
  then
      format="$( echo "$spaced_format" | sed 's/SPACE_WIDTH/119/' )"
  else
      echo "ERROR: Invalid output format '$format_name'!"
      exit 1
  fi
fi


if [[ $show_sa_projects == 1 ]] 
then
    if [[ "$yaml_format" == "$format" ]] 
    then
        format="$yaml_format_with_pid"
    else
        echo "ERROR: --sa-project is only supported for yaml output"
        exit 1
    fi
fi
    

find_sa_project() {
    if [[ "$1" =~ .*serviceAccount:.* ]]
    then
        sa_mail=${1##*serviceAccount:}
        sa_mail=${sa_mail%\"}
        #>&2 echo $1
        #>&2 echo $sa_mail
        project="$(gcloud iam service-accounts describe "$sa_mail" 2> /dev/null | grep projectId || echo "unknown")"
        echo ${project##*projectId:}
    else
        echo "none"
    fi
}

for bucket in $(gsutil ls $project_arg)
do
    bucket_iam="$(gsutil iam get $bucket)"
    echo "$(basename $bucket):"
    bindings="$(
        echo "$bucket_iam" \
            | jq '.bindings[] | "\(.members[]) \(.role)"'
    )"
    
    if [[ $show_sa_projects == 1 ]]
    then
        bindings_old="$bindings"
        bindings=""
        while IFS= read -r line
        do
            account="$(echo $line | awk '{print $1}')"
            bindings="${bindings}${line} $(find_sa_project "$account")
"
        done < <(printf '%s\n' "$bindings_old")
    bindings="${bindings%'
'}"
    fi


    echo "$bindings" | awk "$format"

done

