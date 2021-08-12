#!/usr/bin/env bash

DESCRIPTION="Bundles a script with it's dependencies (meant to be used for scripts from https://github.com/theCalcaholic/bash-utils)"

USAGE="bundle-script.sh [OPTIONS] input output [dependency [dependency [...]]]

  input      path to the original script
  output     path to save the bundled script at.
  dependency path to a dependency to bundle

  Options:
    --check, -c If provided, the bundled script will be called with the given arguments to
                check if it works (i.e. returns with exit code 0).
    --gzip, -z  Use additional gzip compression for bundled scripts"

. "$(dirname "$BASH_SOURCE")/lib/parse_args.sh"
REQUIRED=("input" "output")
KEYWORDS=("--check" "-c" "--gzip;bool" "-z;bool")
set_trap 1
parse_args __USAGE "$USAGE" __DESCRIPTION "$DESCRIPTION" "$@"

input_script="${NAMED_ARGS["input"]}"
output_script="${NAMED_ARGS["output"]}"

if [[ "$(realpath $input_script)" == "$(realpath "$output_script")" ]]
then
    echo "ERROR: input and output scripts can't be equal!" >&2
    exit 1
fi

shopt -s extglob
echo "" > "$output_script"
line_no=1
while read line
do
    if [[ "$line" =~ ^" "*("source "|". ").* ]]
    then
        source_path="${line##source+([[:space:]])}"
        source_path="${line##.+([[:space:]])}"
        source_path="$(eval "echo ${source_path%%*([[:space:]])}")"
        source_path="$(realpath "$source_path")"
        [[ "$?" -eq 0 ]] && [[ -f "${source_path}" ]] || {
            echo "ERROR: Something wen't wrong while analyzing source path in line ${line_no} (does the sourced file exist?):" >&2
            echo "> $line"
        }
        is_replaced="false"
        for dependency in "${ARGS[@]}"
        do
            if [[ "$(realpath ${dependency})" == "$source_path" ]]
            then
                is_replaced="true"
                echo "replacing dependency '${source_path}'"
                {
                  source_file="$(basename "${source_path}")"
                  echo "##### ${source_file} #####"
                  echo -n "source <(echo '"
                  if [[ -z "${KW_ARGS['--gzip']-"${KW_ARGS['-z']}"}" ]]
                  then
                    base64 -w 0 "$source_path"
                  else
                    gzip -cq "$source_path" | base64 -w 0
                  fi
                  echo -n "' | base64 -d"
                  [[ -z "${KW_ARGS['--gzip']-"${KW_ARGS['-z']}"}" ]] || echo -n " | gunzip -cq"
                  echo ")"
                  echo -n "######"
                  for n in $(seq ${#source_file}); do echo -n "#"; done
                  echo "######"
                } >> "$output_script"
            fi
        done
        if [[ "$is_replaced" != "true" ]]
        then
            echo "$line" >> "$output_script"
        fi
    else
        echo "$line" >> "$output_script"
    fi
    line_no="$(($line_no + 1))"
done < "$input_script"

check_args="${KW_ARGS['--check']-${KW_ARGS['-c']}}"
if [[ -n "$check_args" ]]
then
    bash "$output_script" $check_args || true
    bash "$output_script" $check_args > /dev/null 2>&1 || {
        echo "ERROR: The bundled script doesn't seem to work ('bash \"$output_script\" $check_args' terminated with exit code $?)!" >&2
        exit 2
    }
fi

