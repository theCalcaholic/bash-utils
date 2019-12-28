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
    echo "  keepass-mounter [OPTIONS] url"
    echo ""
    echo "  url: The url of your network ressource (e.g. davs://my-domain.org/files/), that will be passed to 'gio mount'"
    echo ""
    echo "  Options:"
    echo "      -b, --backup An (optional) path to store a backup of the database in"
    echo "      -f, --file  The path to your keepass vault (relative to the mount point). Default: database.kdbx"
    echo "      -c, --command The command for executing keepass. '--DB_PATH--' will be replaced with the path to the password database."
    echo ""
    echo "Example:"
    echo "  keepass-mounter -f myvault.kdbx -b ~/keepass-backups"
}

trap print_usage 1 2

vault_path="database.kdbx"
keepass_cmd_pattern='flatpak run --file-forwarding org.keepassxc.KeePassXC @@ "--DB_PATH--" @@'

expected=""
backup_dir=""
backup_file=""
url=""

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
    elif [ -z "$url" ]
    then
        url="$arg"
    fi
done

if [ -z "$url" ]
then
    echo "ERROR: Missing parameter 'url'!"
    print_usage
    exit 1
fi

set -e

secrets_file="$HOME/.keepass-mounter/secrets"

gio mount -u "${url}" || true

if [ -f "$secrets_file" ]
then
    permissions="$(stat -c %a "$secrets_file")"
    g_perms="${permissions%?}"
    g_perms="${g_perms#?}"
    o_perms="${permissions#??}"
    if [[ "$g_perms" == 2 ]] || [[ "$g_perms" == 3 ]] || [[ "$g_perms" == 6 ]] || [[ "$g_perms" == 7 ]] \
        || [[ "$o_perms" == 2 ]] || [[ "$o_perms" == 3 ]] || [[ "$o_perms" == 6 ]] || [[ "$o_perms" == 7 ]]
    then
        echo "ERROR: secrets file has dangerous permissions set! Refusing to continue."
        echo "Please correct this by running 'chmod 600 $secrets_file'"
        exit 2
    fi
        
    mount_cmd="gio mount ${url} < $secrets_file"
else
    mount_cmd="gio mount ${url}"
fi

bash -c "$mount_cmd" || {
    echo "Something went wrong while mounting the remote storage! Check if it can be reached"
    sleep 2
    exit 1
}

mount_path="/run/user/$(id -u)/gvfs/$(gio info "$url" | grep -oPe '(?<=id::filesystem: ).*')"

if [ ! -d "$mount_path" ]
then
    echo "Failed to find mount path for ressource! '${mount_path}' is not a directory."
    sleep 2
    exit 2
fi

sleep 1
if [ ! -z "$backup_dir" ]
then
    mkdir -p "$backup_dir" || true
    [ -f "$backup_dir/$backup_file" ] && \
        mv "$backup_dir/$backup_file" "$backup_dir/${backup_file}.old"

    cp "$mount_path/$vault_path" "$backup_dir/$backup_file"
fi

keepass_cmd="$(sed "s|--DB\_PATH--|${mount_path%/}/$vault_path|g" <<< "$keepass_cmd_pattern")"

nohup bash -c "$keepass_cmd" &

