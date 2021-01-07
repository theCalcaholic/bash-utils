#!/usr/bin/env bash


USAGE="git-replace-author.sh old-email new-name new-email

  old-email: The email of the author to replace
  new-name: The new author's name
  new-email: The new author's email"

set -e
. "$(dirname "$0")/lib/parse_args.sh"
set_trap 1 2
parse_args __USAGE "$USAGE" "$@"


export OLD_EMAIL=${ARGS[0]?}
export CORRECT_NAME=${ARGS[1]?}
export CORRECT_EMAIL=${ARGS[2]?}

git filter-branch --env-filter '

if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
then
  export GIT_COMMITTER_NAME="$CORRECT_NAME"
  export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi

if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_AUTHOR_NAME="$CORRECT_NAME"
    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --tag-name-filter cat -- --branches --tags

