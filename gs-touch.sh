#!/usr/bin/env bash


DESCRIPTION="Move file in GCS bucket in order to trigger events (e.g. for cloud functions)"
USAGE="gs-touch.sh file-uri

  file-uri gs uri for file, e.g. gs://my-storage-bucket/foo.bar"
. "$(dirname "$BASH_SOURCE")/lib/parse_args.sh"
REQUIRED=("file-uri")
parse_args __USAGE "$USAGE" __DESCRIPTION "$DESCRIPTION" "$@"
set_trap 1 2

gs_file="${NAMED_ARGS['file-uri']}"
tmp_file="$(dirname "$gs_file")/.tmp_$(basename "$gs_file")"
echo "Moving '$gs_file' to '$tmp_file' and back..."
gsutil mv "$gs_file" "$tmp_file" && gsutil mv "$tmp_file" "$gs_file"

