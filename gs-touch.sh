#!/usr/bin/env bash

#
# Move file in GCS bucket in order to trigger events (e.g. for cloud functions)
#

gs_file="${1?}"
tmp_file="$(dirname "$gs_file")/.tmp_$(basename "$gs_file")"
echo "Moving '$gs_file' to '$tmp_file' and back..."
gsutil mv "$gs_file" "$tmp_file" && gsutil mv "$tmp_file" "$gs_file"

