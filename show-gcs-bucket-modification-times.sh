#!/usr/bin/env bash

#
# Shows you the modification times for all buckets in your google project (based on file modification
# times or as a fallback bucket metadata).
#

set -e

LC_TIME=en_US.UTF-8

PROJECT="YOUR-GCP-PROJECT-ID"

print_usage() {
    echo "show_bucket_access [OPTIONS]"
    echo "Options:"
    echo "    -f, --fetch Fetch bucket details before printing update times. If not specified, the details need to be present in the given path (see --path)"
    echo "    --qa Fetch buckets in clcl-core-qa instead of clcl-core-prod"
    echo "    -p, --path  Specifies the working directory (where the bucket info files will be downloaded to/are expected to be). Default is '.'"
}

trap print_usage 1

path=""
expected=""
fetch=0

for arg in $@
do
	if [ "$expected" == "path" ]
	then
		path="$arg"
	fi

	if [ "$arg" == "--path" ] || [ "$arg" == "-p" ]
	then
		expected='path'
	elif [ "$arg" == "--fetch" ] || [ "$arg" == "-f" ]
	then
		fetch=1
	elif [ "$arg" == "--qa" ]
	then
		PROJECT=clcl-core-qa
	elif [ "$arg" == "--help" ] || [ "$arg" == "-h" ]
    then
        print_usage
		exit 0
	fi
done

if [ -z "$path" ]
then
	path="."
fi

path=${path%%/}

if [ "$fetch" == "1" ]
then
	rm "$path"/*.info

	echo "Fetching bucket details..."
	for bucket in $(gsutil ls -p "$PROJECT")
	do
		echo "Fetching bucket '$bucket'..."
		echo "  Fetching Details..."
		bucketname=${bucket//gs:\/\//}
		bucketname=${bucketname//\//}
		gsutil ls -p "$PROJECT" -Lb $bucket
		gsutil ls -p "$PROJECT" -Lb $bucket >> "$path/$bucketname.info"
		echo "  Fetching file update timestamps..."
		file_dates=$( gsutil ls -p  "$PROJECT" -l "${bucket}**" \
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

