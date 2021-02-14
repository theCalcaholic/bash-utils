#!/usr/bin/env bash


USAGE="git-replace-author.sh old-email new-name new-email

  old-email: The email of the author to replace
  new-name: The new author's name
  new-email: The new author's email"

set -e
. "$(dirname "$BASH_SOURCE")/lib/parse_args.sh"
REQUIRED=("old-email" "new-name" "new-email")
parse_args __USAGE "$USAGE" "$@"
set_trap 1 2


export OLD_EMAIL=${NAMED_ARGS['old-email']}
export CORRECT_NAME=${NAMED_ARGS['new-name']}
export CORRECT_EMAIL=${NAMED_ARGS['new-email']}

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

