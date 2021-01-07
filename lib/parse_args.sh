#!/usr/bin/env bash

parse_args() {
  #local keywords=("--project" "--region" "--zone" "--machine-type")
  local expected=""
  local should_print_help="false"
  [[ -n "$KEYWORDS" ]] || declare -a KEYWORDS
  declare -xAg KW_ARGS
  declare -xag ARGS

  for arg in "$@"
  do
    if [[ -n "$expected" ]]
    then
      KW_ARGS["$expected"]="$arg"
      expected=""
    elif [[ "__USAGE" == "$arg" ]]
    then
      expected="USAGE"
    elif [[ "__DESCRIPTION" == "$arg" ]]
    then
      expected="DESCRIPTION"
    elif [[ " ${KEYWORDS[*]} " =~ .*" $arg ".* ]]
    then
      expected="$arg"
    else
      if [[ "$arg" == "--help" ]] || [[ "$arg" == "-h" ]]
      then
        should_print_help="true"
      fi
      ARGS+=("$arg")
    fi
  done

  if [[ "$should_print_help" == "true" ]]
  then
    print_description
    echo ""
    print_usage
    exit 0
  fi

}

print_usage() {
    echo "USAGE:"
    echo "  ${KW_ARGS[USAGE]:-'No usage message found'}"
}

print_description() {
    echo "${KW_ARGS[DESCRIPTION]:-'No usage message found'}"
}

set_trap() {
  trap "[[ ' $* ' =~ \$? ]] && { echo ""; print_usage; }" EXIT 
}
