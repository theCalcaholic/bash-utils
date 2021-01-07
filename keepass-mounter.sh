#!/usr/bin/env bash


DESCRIPTION="Script to mount a network (e.g. sshfs/davfs) directory and subsequently start keepass with a vault in said directory

Requires 
  - the flatpak version of KeepassXC to be installed (or whatever version is passed via the -c argument)
  - an fstab entry for the desired mount point (using davfs2)"

USAGE="keepass-mounter.sh mount-point db-file [OPTIONS]

  mount-point The directory to mount the remote storage into
  db-file     The path to your keepass vault (relative to the mount point)

  Options:
      -b, --backup  A path for storing a database backup
      -c, --command The command for executing keepass (defaults to the flatpak version of keepass).
                    '--DB_PATH--' will be replaced with the path to the password database.

Example:
  keepass-mounter.sh /media/myUser/keepass myvault.kdbx -b ~/keepass-backups"

set -e
. "$(dirname "$0")/lib/parse_args.sh"
set_trap 1 2
KEYWORDS=("-b" "--backup" "-c" "--command")
parse_args __USAGE "$USAGE" __DESCRIPTION "$DESCRIPTION" "$@"

mount_path="${ARGS[0]?}"
mount_path="${mount_path%/}"
vault_path="${ARGS[1]?}"

keepass_cmd_pattern='flatpak run --file-forwarding org.keepassxc.KeePassXC @@ "--DB_PATH--" @@'
keepass_cmd_pattern="${KW_ARGS["-c"]-$keepass_cmd_pattern}"
keepass_cmd_pattern="${KW_ARGS["--command"]-$keepass_cmd_pattern}"

backup_path=""
backup_path="${KW_ARGS["-b"]-$backup_path}"
backup_path="${KW_ARGS["--backup"]-$backup_path}"
if [[ "$backup_path" =~ ^.*\.kdbx$ ]]
then
  backup_dir="$(dirname "$backup_path")"
  backup_file="$(basename "$backup_path")"
elif [[ -n "$backup_path" ]]
then
  backup_dir="$backup_path"
fi


mkdir -p "$mount_path" || true
fusermount -u "$mount_path" || echo "Nothing mounted in $mount_path - no need to unmount..."
mount "$mount_path" || {
    echo "Something went wrong while mounting the remote storage! Check if it can be reached"
    exit 3
}

sleep 1
if [ ! -z "$backup_dir" ]
then
    mkdir -p "$backup_dir" || true
    [ -f "$backup_dir/$backup_file" ] && \
        mv "$backup_dir/$backup_file" "$backup_dir/${backup_file}.old"

    cp "$mount_path/$vault_path" "$backup_dir/$backup_file"
fi

#nohup flatpak run --file-forwarding org.keepassxc.KeePassXC @@ "${mount_path%/}/$vault_path" @@ &
keepass_cmd="$(sed "s|--DB\_PATH--|${mount_path%/}/$vault_path|g" <<< "$keepass_cmd_pattern")"

nohup bash -c "$keepass_cmd" &

