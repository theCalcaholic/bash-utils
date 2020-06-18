#!/usr/bin/env bash

#
# Script to mount a network (e.g. sshfs/davfs) directory and subsequently start keepass with 
# a vault in said directory
#
# Requires 
#   - the flatpak version of KeepassXC to be installed (or whatever version is passed via the -c argument)
#   - an fstab entry for the desired mount point
#

print_usage() {
    echo "USAGE:"
    echo "  keepass-mounter [OPTIONS]"
    echo ""
    echo "  Options:"
    echo "      -b, --backup An (optional) path to store a backup of the database in"
    echo "      -m, --mount The directory to mount the remote storage into"
    echo "      -f, --file  The path to your keepass vault (relative to the mount point)"
    echo "      -c, --command The command for executing keepass. '--DB_PATH--' will be replaced with the path to the password database."
    echo ""
    echo "Example:"
    echo "  keepass-mounter -m /media/myUser/keepass -f myvault.kdbx -b ~/keepass-backups"
}

trap print_usage 1 2

mount_path="/media/keepass"
vault_path="vault.kdbx"
keepass_cmd_pattern='flatpak run --file-forwarding org.keepassxc.KeePassXC @@ "--DB_PATH--" @@'

expected=""
backup_dir=""
backup_file=""

for arg in "$@"
do
    if [ "$expected" == "backup" ]
    then
        if [[ "$arg" =~ ^.*\.kdbx$ ]]
        then
            backup_dir="$(dirname "$arg")"
            backup_file="$(basename "$arg")"
        else
            backup_dir="$arg"
        fi
        backup_dir="${backup_dir%/}"
    elif [ "$expected" == "mount" ]
    then
        mount_path="${arg%/}"
    elif [ "$expected" == "file" ]
    then
        vault_path="${arg%/}"
    elif [ "$expected" == "command" ]
    then
        keepass_cmd_pattern="$arg"
    fi

    if [ ! -z "$expected" ]
    then
        expected=""
        continue
    fi

    if [ "$arg" == "--backup" ] || [ "$arg" == "-b" ]
    then
        expected="backup"
    elif [ "$arg" == "--mount" ] || [ "$arg" == "-m" ]
    then
        expected="mount"
    elif [ "$arg" == "--help" ] || [ "$arg" == "-h" ]
    then
        print_usage
        exit 0
    elif [ "$arg" == "--file" ] || [ "$arg" == "-f" ]
    then
        expected="file"
    elif [ "$arg" == "--command" ] || [ "$arg" == "-c" ]
    then
        expected="command"
    fi
done

set -e

mkdir -p "$mount_path" || true
fusermount -u "$mount_path" || echo "Nothing mounted in $mount_path - no need to unmount..."
mount "$mount_path" || {
    echo "Something went wrong while mounting the remote storage! Check if it can be reached"
    exit 1
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

