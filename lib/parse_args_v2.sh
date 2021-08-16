#!/usr/bin/env bash

__BASHARGS_DEBUG=
shopt -s extglob


parse_args() {
  if [[ -n "${KW_ARGS[*]}" ]] || [[ -n "${NAMED_ARGS[*]}" ]] || [[ -n "${ARGS[*]}" ]]
  then
    if [[ "${BASHARGS_ALLOW_OVERRIDE}" != "true" ]]
    then
      echo "$BASHARGS_ALLOW_OVERRIDE"
      echo 'ERROR: Parsed arguments from a previous run of parse_args have been found (KW_ARGS, NAMED_ARGS or ARGS)!' \
        'If you really want to override these variables set BASHARGS_ALLOW_OVERRIDE=true' >&2
      return 54
    fi
  fi

  clear_args

  local expected=""
  local should_print_help="false"
  [[ -n "$KEYWORDS" ]] || declare -a KEYWORDS=()
  [[ -n "$REQUIRED" ]] || declare -a REQUIRED=()
  local required=("${REQUIRED[@]}")
  local kw_names arg_config kw_name type
  declare -A KW_MAP
  declare -A KW_TYPE
  declare -A NAMED_TYPE
  declare -xAg KW_ARGS
  declare -xAg NAMED_ARGS
  declare -xag ARGS
  local newline="
"

  for kw in "${KEYWORDS[@]}"
  do

    IFS=';' read -ra arg_config <<<"$kw"
    IFS='|' read -ra kw_names <<<"${arg_config[0]}"

    [[ -n "${kw_names[0]}" ]] || { echo "Error parsing configuration for keyword argument '$kw'!" >&2; return 53; }
    for kw_name in "${kw_names[@]}"
    do
      KW_MAP["$kw_name"]="${kw_names[0]}"
    done
    KW_TYPE["${kw_names[0]}"]="${arg_config[1]:-string}"

  done

  for arg in "${REQUIRED[@]}"
  do
    IFS=';' read -ra arg_config <<<"$arg"
    NAMED_TYPE["${arg_config[0]}"]="${arg_config[1]:-string}"
  done

  if [[ -n "$__BASHARGS_DEBUG" ]]
  then
    echo "named args:"
    for arg in "${!NAMED_TYPE[@]}"
    do
      echo "  $arg (${NAMED_TYPE["$arg"]})"
    done

    echo "keyword args:"
    for kw in "${!KW_MAP[@]}"
    do
      kw_name="${KW_MAP["$kw"]}"
      echo "  $kw -> $kw_name (${KW_TYPE[$kw_name]})"
    done
    echo ""
  fi

  for arg in "$@"
  do

    if [[ -n "$expected" ]] # we're expecting the value for a kw arg
    then
      if [[ "$type" == "int" ]] && ! test "$arg" -eq "$arg" 2> /dev/null
      then
        echo "ERROR: Expected a number but got '$arg'!" >&2
        echo ""
        print_usage
        return 52
      fi
      if [[ -n "${KW_ARGS["$expected"]}" ]]
      then
        if [[ "$type" == "list" ]]
        then
          KW_ARGS["$expected"]="${KW_ARGS["$expected"]}$newline$arg"
        else
          echo "ERROR: Duplicate argument '$expected'!" >&2
        fi
      else  
        KW_ARGS["$expected"]="$arg"
      fi
      expected=""
      type=""
    elif [[ -n "${KW_MAP["$arg"]}" ]]
    then
      kw_name="${KW_MAP["$arg"]}"
      type="${KW_TYPE["$kw_name"]}"

      if [[ "$type" == "bool" ]]
      then
        KW_ARGS["$kw_name"]="true"
      else
        expected="$kw_name"
      fi
    else
      if [[ "$arg" == "--help" ]] || [[ "$arg" == "-h" ]]
      then
        type=""
        should_print_help="true"
      fi

      if [[ -n "${required[0]}" ]]
      then
        type="${NAMED_TYPE["${required[0]}"]}"
        NAMED_ARGS["$required"]="$arg"
        required=("${required[@]:1}")
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
    return 50
  elif [[ -n "${required[0]}" ]]
  then
      echo "ERROR: The following required arguments are missing: ${required[*]%;*}" >&2
      print_usage
      return 51
  fi


}

print_usage() {

    if ! [[ "$(declare -p USAGE)" =~ "declare -A" ]]
    then
      echo "$USAGE"
      return 0
    fi

    declare -a extra_args
    for arg in "${!USAGE[@]}"
    do
      if ! [[ " $REQUIRED " =~ .*" $arg ".* ]] && ! [[ " ${KEYWORDS[@]/%;*/} " =~ .*(" "|"|")"$arg"(" "|"|").* ]] 
      then
        extra_args+=("$arg")
      fi
    done

    if [[ -n "${USAGE['COMMAND']}" ]]
    then
      name="${USAGE['COMMAND']}"
    else
      name="$(basename "$(find_caller)")"
    fi
    kws=("${KEYWORDS[@]/#/[}")
    kws=("${kws[@]/%;*/}")

    echo "USAGE:"
    echo -n "  $name "
    [[ -z "${kws[*]}" ]]        || echo -n "${kws[*]/%/]} "
    [[ -z "${REQUIRED[*]}" ]]   || echo -n "${REQUIRED[@]} "
    [[ -z "${extra_args[*]}" ]] || printf "[%s] " "${extra_args[@]}"
    echo ""
    
    if [[ "${#USAGE[@]}" -eq 0 ]]
    then
      return 0
    fi

    local usage
    declare -A usage
    for key in "${!USAGE[@]}"
    do
      usage["$key"]="${USAGE["$key"]}"
    done

    # Print required args
    for arg in "${REQUIRED[@]}"
    do
      if [[ -n "${usage[$arg]}" ]]
      then
        printf %-20s "    ${arg}"
        echo " ${usage[$arg]}"
        unset usage["$arg"]
      fi
    done

    # Print extra args
    for arg in "${extra_args[@]}"
    do
      if [[ -n "${usage[$arg]}" ]]
      then
        printf %-20s "    ${arg}"
        echo " ${usage[$arg]}"
        unset usage["$arg"]
      fi
    done

    if [[ "${#usage[@]}" -ne 0 ]]
    then
      echo ""
      echo "  OPTIONS:"
      local kw_summaries kw_name placeholder kw_names_width
      declare -A kw_summaries
      kw_names_width=0
      for kw in "${!KW_MAP[@]}";
      do
        kw_name="${KW_MAP["$kw"]}"
        
        type="${KW_TYPE["$kw_name"]}"
        if [[ "$type" == "string" ]] || [[ "$type" == "list" ]]
        then
          placeholder=" <value>"
        elif [[ "$type" == "int" ]]
        then
          placeholder=" <number>"
        else
          placeholder=""
        fi

        if [[ -z "${kw_summaries["$kw_name"]}" ]]
        then
          kw_summaries["$kw_name"]="$kw${placeholder:-}"
        else
          kw_summaries["$kw_name"]="${kw_summaries["$kw_name"]}, $kw${placeholder:-      }"
        fi
        kw_summary="${kw_summaries["$kw_name"]}"
        [[ ${#kw_summary} -lt ${kw_names_width} ]] || kw_names_width=${#kw_summary}
      done

      for kw_name in "${!kw_summaries[@]}";
      do
        kw_summary="${kw_summaries["$kw_name"]}"
        type="${KW_TYPE["$kw_name"]}"

        if [[ "$type" == "list" ]]
        then
          addition="(Can be supplied multiple times)"
        else
          addition=""
        fi

        if [[ -n "${usage["$kw_name"]}" ]]
        then
          printf %-$(( kw_names_width + 4))s "    ${kw_summary}"
          echo "    ${usage[$kw_name]}${addition:+ ${addition}}"
        fi
      done
    fi

    # echo "  ${KW_ARGS[USAGE]:-"<No usage message found>"}"
}

print_description() {
    echo "${DESCRIPTION:-"<No description found>"}"
}

set_trap() {
  trap "[[ ' $* ' =~ \$? ]] && { echo ""; print_usage; }" EXIT 
}

find_caller() {

  for candidate in "${BASH_SOURCE[@]}";
  do
    if ! [[ "$(realpath $candidate)" == "$(realpath ${BASH_SOURCE[0]})" ]]
    then
      echo "$candidate"
      return 0
    fi
  done
  echo "WARN: No caller found!" >&2
  return 1
}

clear_args() {
  unset KW_ARGS
  unset NAMED_ARGS
  unset ARGS
  unset KW_MAP
  unset KW_TYPE
  unset NAMED_TYPE
}

