#!/usr/bin/env bash


USAGE="Move file in GCS bucket in order to trigger events (e.g. for cloud functions)"
. "$(dirname "$0")/lib/parse_args.sh"
set_trap 1 2
parse_args __USAGE "$USAGE" "$@"


gs_file="${ARGS[0]?}"
tmp_file="$(dirname "$gs_file")/.tmp_$(basename "$gs_file")"
echo "Moving '$gs_file' to '$tmp_file' and back..."
gsutil mv "$gs_file" "$tmp_file" && gsutil mv "$tmp_file" "$gs_file"

