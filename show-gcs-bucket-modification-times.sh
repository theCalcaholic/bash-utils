#!/usr/bin/env bash


DESCRIPTION="Shows you the modification times for all buckets in your google project (based on file modification times or as a fallback bucket metadata)."

set -e

LC_TIME=en_US.UTF-8


USAGE="show_bucket_access [OPTIONS]

Options:
    -f, --fetch   Fetch bucket details before printing update times. If not specified, the details
                  need to be present in the given path (see --dir)
    -p, --project Fetch buckets from given project
    -d, --dir     Specifies the working directory (where the bucket info files will be downloaded
                  to/are expected to be). Default is '.'"

. "$(dirname "$BASH_SOURCE")/lib/parse_args.sh"
KEYWORDS=("-f;bool" "--fetch;bool" "-p" "--project" "-d" "--dir")
parse_args __USAGE "$USAGE" __DESCRIPTION "$DESCRIPTION" "$@"
set_trap 1 2

gc_args=()

path="${KW_ARGS['-d']-.}"
path="${KW_ARGS['--dir']-$path}"
path="${path%%/}"

project="${KW_ARGS['--project']-${KW_ARGS['-p']}}"
echo "project: $project"

if [[ -n "$project" ]]
then
  gc_args+=("-p" "$project")
fi

fetch="${KW_ARGS['-f']-false}"
fetch="${KW_ARGS['--fetch']-$fetch}"

if [[ "$fetch" == "true" ]]
then
	rm "$path"/*.info || true

	echo "Fetching bucket details..."
	for bucket in $(gsutil ls "${gc_args[@]}")
	do
		echo "Fetching bucket '$bucket'..."
		echo "  Fetching Details..."
		bucketname=${bucket//gs:\/\//}
		bucketname=${bucketname//\//}
		gsutil ls "${gc_args[@]}" -Lb $bucket
		gsutil ls "${gc_args[@]}" -Lb $bucket >> "$path/$bucketname.info"
		echo "  Fetching file update timestamps..."
		file_dates=$( gsutil ls "${gc_args[@]}" -l "${bucket}**" \
			| grep -v "TOTAL: " \
			| tr -s " " \
			| cut -d " " -f 3 \
			| xargs -L1 -I $ date --date="$" +'%Y-%m-%d' \
			| sort -r)
		
		update_timestamp=$(cat "$path/$bucketname.info" \
			| grep "Time updated:" \
			| cut -d " " -f 3- \
			| xargs -I $ date --date="$" +'%Y-%m-%d' )
		
		echo "---TIMESTAMPS---" >> "$path/$bucketname.info"
		echo "---TIMESTAMPS---"
		echo "$update_timestamp" >> "$path/$bucketname.info"
		echo "$update_timestamp"
		echo "$file_dates" >> "$path/$bucketname.info"
		echo "$file_dates"

	done
fi

echo ""
echo "EVALUATION"
echo "=========="

(
	for bucket in $path/*.info
	do 
		timestamp=$(cat "$path/$bucket" \
			| grep -e "---TIMESTAMPS---" -C0 -A2 \
			| grep -v -e "^$" -e "---TIMESTAMPS---" \
			| sort -r \
			| head -n 1 )
		printf "%-50s %s\n" "$(basename $bucket .info):" "$timestamp"
	done

) | sort -k 2,2 

