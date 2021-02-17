#!/usr/bin/env bash

__BASHARGS_DEBUG=

get_type_if_exists() {

  local type cut
  local debug="$__BASHARGS_DEBUG"
  [[ -z "$debug" ]] || echo "get_type_if_exists $@" >&2 
   
  if [[ "${1?}" == "kw-arg" ]] && [[ " ${KEYWORDS[*]} " =~ .*" ${2?}"(";"|" ").* ]]
  then
    cut="${KEYWORDS[*]}"
  elif [[ "${1?}" == "named-arg" ]] && [[ " ${REQUIRED[*]} " =~ .*" ${2?}"(";"|" ").* ]]
  then
    cut=" ${REQUIRED[*]} "
  fi

  if [[ -n "$cut" ]]
  then
    cut="${cut#* ${2}}"
    [[ -z "$debug" ]] || echo "  1. |${cut}|" >&2
    if [[ "$cut" =~ ^";".* ]]
    then
      type="${cut%% *}"
      [[ -z "$debug" ]] || echo "  2. |${type}|" >&2
      type="${type#*;}"
      [[ -z "$debug" ]] || echo "  3. |${type}|" >&2
    fi
    [[ -z "$debug" ]] || echo "  ${type:-string}" >&2
    echo -n "${type:-string}"
    return 0
  fi

  [[ -z "$debug" ]] || echo "  not found" >&2
  return 1
    
}

parse_args() {
  #local keywords=("--project" "--region" "--zone" "--machine-type")
  local type expected
  local should_print_help="false"
  [[ -n "$KEYWORDS" ]] || declare -a KEYWORDS
  [[ -n "$REQUIRED" ]] || declare -a REQUIRED
  declare -xAg KW_ARGS
  declare -xAg NAMED_ARGS
  declare -xag ARGS

  for arg in "$@"
  do

    if [[ -n "$expected" ]]
    then
      if [[ "$type" == "int" ]] && ! test "$arg" -eq "$arg" 2> /dev/null
      then
        echo "ERROR: Expected a number but got '$arg'!"
        echo ""
        print_usage
        exit 52
      fi
      KW_ARGS["$expected"]="$arg"
      expected=""
      type=""
    elif [[ "__USAGE" == "$arg" ]]
    then
      type="string"
      expected="USAGE"
    elif [[ "__DESCRIPTION" == "$arg" ]]
    then
      type="string"
      expected="DESCRIPTION"
    elif type="$(get_type_if_exists kw-arg "$arg")"
    then
      if [[ "$type" == "bool" ]]
      then
        KW_ARGS["$arg"]="true"
      else
        expected="$arg"
      fi
    else
      if [[ "$arg" == "--help" ]] || [[ "$arg" == "-h" ]]
      then
        type=""
        should_print_help="true"
      fi

      if [[ -n "$REQUIRED" ]]
      then
        type="$(get_type_if_exists named-arg "$REQUIRED")"
        NAMED_ARGS["$REQUIRED"]="$arg"
        REQUIRED=("${REQUIRED[@]:1}")
      else
        ARGS+=("$arg")
      fi
    fi
  done
  
  if [[ "$should_print_help" == "true" ]]
  then
    print_description
    echo ""
    print_usage
    exit 0
  elif [[ -n "$REQUIRED" ]]
  then
      echo "ERROR: The following required arguments are missing: ${REQUIRED[*]%;*}"
      print_usage
      exit 51
  fi


}

print_usage() {
    echo "USAGE:"
    echo "  ${KW_ARGS[USAGE]:-"<No usage message found>"}"
}

print_description() {
    echo "${KW_ARGS[DESCRIPTION]:-"<No description found>"}"
}

set_trap() {
  trap "[[ ' $* ' =~ \$? ]] && { echo ""; print_usage; }" EXIT 
}

wait_for_enter() {
    while true
    do
        read -s -N 1 -t 1 key
        if [[ "$key" == $'\x0a' ]]
        then
            break;
        fi
    done
}
