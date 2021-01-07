#!/usr/bin/env bash

parse_args() {
  #local keywords=("--project" "--region" "--zone" "--machine-type")
  local expected=""
  [[ -n "$KEYWORDS" ]] || declare -a KEYWORDS
  declare -xAg KW_ARGS
  declare -xag ARGS

  for arg in "$@"
  do
    if [[ -n "$expected" ]]
    then
      KW_ARGS["$expected"]="$arg"
      expected=""
    elif [[ " ${KEYWORDS[*]} " =~ .*" $arg ".* ]]
    then
      expected="$arg"
    else
      ARGS+=("$arg")
    fi
  done

}

