#!/usr/bin/env bash

set -e
. "$(cd "${BASH_SOURCE[0]%/*}" && pwd)/lib/parse_args_v2.sh"

KEYWORDS=("-k|--keep;int" "-d|--dayly;int" "-o|--hourly;int")
REQUIRED=("files" "backup_directory")

DESCRIPTION="Create backups of the specified files in target directory"
declare -A USAGE
USAGE[files]="The files to backup"
USAGE[backup_directory]="The path to the directory where the backups should be stored"
USAGE['-k']="<number> of backups to keep per run (default: 3)"
USAGE['-d']="<number> of daily backups to keep (default: 7)"
USAGE['-o']="<number> of hourly backups to keep (default: 12)"

#Example:
#  rotating-backup.sh \$HOME/Documents/important/* /run/media/nfs/backup

parse_args "$@"
set_trap 1 2

if [[ ${#ARGS[@]} -eq 0 ]]
then
  FILES=("${NAMED_ARGS['files']}")
  BKP_DIR="${NAMED_ARGS['backup_directory']}"
else
  FILES=("${NAMED_ARGS['files']}" "${NAMED_ARGS['backup_directory']}" "${ARGS[@]::${#ARGS[@]}-1}")
  BKP_DIR="${ARGS[${#ARGS[@]}-1]}"
fi
KEEP="${KW_ARGS['-k']:-3}"
DAILY="${KW_ARGS['-d']:-7}"
HOURLY="${KW_ARGS['-o']:-12}"

set -u

HOUR="$(date +%H)"
DAY="$(date +%y-%m-%d)"

echo "Backing up ${#FILES[@]} files to '${BKP_DIR}' and keep $KEEP backups per file, $HOURLY backups per hour+file and $DAILY backups per day+file."

mkdir -p "$BKP_DIR"

if ! [[ -d "$BKP_DIR" ]]
then
  echo "ERROR: Failed to create backup directory '$BKP_DIR'"
  exit 3
fi


cleanup_backups() {
  local prefix keep backups bkp_count to_delete do_rotate
  prefix="${1?Missing argument: prefix}"
  keep="${2?Missing argument: keep}"
  do_rotate="${3:-false}"

  mapfile -d '' backups < <(find "${BKP_DIR}" -type f -name "${prefix}*" -print0 | sort -rz)
  bkp_count="${#backups[@]}"
  to_delete="$((bkp_count - keep - 1))"

  for bkp in "${backups[@]}"
  do
    if [[ "${to_delete}" -le 0 ]]
    then
      break
    fi

    chmod u+w "${bkp}"
    rm "${bkp}"
    to_delete="$((to_delete-1))"
  done
}


echo "Cleaning up old backups..."

for f in "${FILES[@]}"
do
  bkp_path="${BKP_DIR}/$(basename "$f")"
  cleanup_backups "${bkp_path}.bkp-" "${KEEP}"
  cleanup_backups "${bkp_path}.hourly-" "${HOURLY}"
  cleanup_backups "${bkp_path}.daily-" "${DAILY}"
  if [[ -f "${bkp_path}" ]] && [[ "$KEEP" -gt 1 ]]
  then
    chmod u+w "${bkp_path}"
    rm "${bkp_path}"
  fi
done

echo "done."
echo "Rotating backups..."

i=$KEEP
while ((i>=0))
do
  for f in "${FILES[@]}"
  do
    f_name="$(basename "$f")"
    curr_path="${BKP_DIR}/${f_name}.${i}"
    prev_path="${BKP_DIR}/${f_name}"
    if [[ $i -ne 0 ]]
    then
      prev_path="${prev_path}.$((i-1))"
    fi
    if [[ -f "${prev_path}" ]]
    then
      chmod u+w "${prev_path}"
      mv "${prev_path}" "${curr_path}"
      chmod ugo-w "${curr_path}"
    fi
  done
  i=$((i-1))
done

echo "done."
echo "Creating new backups..."

for f in "${FILES[@]}"
do
  bkp_path="${BKP_DIR}/$(basename "$f")"
  if [[ "$KEEP" -gt 0 ]]
  then
    cp "${f}" "${bkp_path}"
    chmod ugo-w "${bkp_path}"
  fi
  if [[ "$HOURLY" -gt 0 ]]
  then
    if [[ -f "${bkp_path}.hourly-$HOUR" ]]
    then
      chmod u+w "${bkp_path}.hourly-$HOUR"
    fi
    cp "${f}" "${bkp_path}.hourly-$HOUR"
    chmod ugo-w "${bkp_path}.hourly-$HOUR"
  fi
  if [[ "$DAILY" -gt 0 ]]
  then
    if [[ -f "${bkp_path}.daily-$DAY" ]]
    then
      chmod u+w "${bkp_path}.daily-$DAY"
    fi
    cp "${f}" "${bkp_path}.daily-$DAY"
    chmod ugo-w "${bkp_path}.daily-$DAY"
  fi
done

echo "done."

