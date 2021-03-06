#!/usr/bin/env bash

DESCRIPTION="Interactively open the urls for all passwords within a keepass database file (requires keepassxc.cli)"
USAGE="keepassxc-open-all-urls.sh [OPTIONS] keepass-db

    keepass-db The path to the keepass database that should be parsed

    Options:
      -b, --browser <browser-command> The command to launch your browser. Will be called as such: '<command> %url%'
      -g, --group <group-path>        Only show password entries for the given group
      -h, --help                      Show this message"
. "$(dirname "$BASH_SOURCE")/lib/parse_args.sh"
KEYWORDS=("-b" "--browser" "-g" "--group")
REQUIRED=("keepass-db")
parse_args __DESCRIPTION "$DESCRIPTION" __USAGE "$USAGE" "$@"

browser_cmd="${KW_ARGS['-b']-}"
browser_cmd="${KW_ARGS['--browser']-${browser_cmd}}"
keepass_group="${KW_ARGS['--group']-${KW_ARGS['-g']}}"

set_trap 2
set -e

if [[ -z "$browser_cmd" ]]
then
    for cmd in xdg-open firefox chromium chrome
    do
      command -v "$cmd" > /dev/null && {
          browser_cmd="$cmd"
          break
      } || true
    done
elif ! command -v "$browser_cmd" > /dev/null
then
    echo "ERROR: Could not find the specified browser command '$browser_cmd'!"
    exit 2
fi

if [[ -z "$browser_cmd" ]]
then
    echo "ERROR: Could not find any browser! Please specify a browser command/executable " \
         "with -b or --browser"
    exit 2
fi

echo "Using browser command '$browser_cmd'..."

read -rs -p "Please enter the database password for '$(basename "${NAMED_ARGS['keepass-db']}")':" pw
echo ""
while read -r -u 3 entry
do 
    url="$(echo "$pw" \
            | keepassxc.cli show -a URL ~/keepass_backup/personal_accounts.kdbx "$entry" \
            2>/dev/null || true)"
    if [[ -z "$url" ]]
    then 
        echo "No URL for entry \"$entry\"..."
    else
        echo "Opening URL for entry \"$entry\"..."
        "${browser_cmd}" "$url"
    fi
    echo "[Enter] to proceed..."
    read -s
done 3< <(echo "$pw" \
            | keepassxc.cli ls -Rf ~/keepass_backup/personal_accounts.kdbx "${keepass_group-/}" \
            2> /dev/null)

