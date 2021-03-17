#!/usr/bin/env bash

USAGE="USAGE:
  setup-secure-dump [OPTIONS]

  Options:
      -m, --mount mountpoint    The directory to mount the container to 
                                (must be empty or nonexistent)
      -c, --container container The location where the container image should be created
                                (must not exist if -d was not given)
      -d, --delete              Remove an existing container
      -s, --size                The size of the container (e.g. '1G', '500MB')
      -h, --help                Print this help message"

. "$(dirname $BASH_SOURCE)/lib/parse_args.sh"
KEYWORDS=("-m" "--mount" "-c" "--container" "-d;bool" "--delete;bool" "-s" "--size" "--i-really-want-to;bool")
parse_args __USAGE "$USAGE" "$@"
set_trap 1 2

if [[ "${KW_ARGS['--i-really-want-to']}" != 'true' ]]
then
    echo "!!! DEPRECATION WARNING !!!"
    echo "Since writing this script, I have found a (actually 2) way better and easier solution for the problem it tries to solve."
    echo "Please, check out either https://www.cryfs.org/ or https://nuetzlich.net/gocryptfs/"
    echo "These tools are easy to use and it shouldn't be hard to use them with a random key."
    echo ""
    echo "For example, in order to do basically the same thing as this script with cryfs, just add the following code to your ~/.bashrc:
if ! mountpoint -q -- "~/secure_dump"
then
  [ -d ~/.secure_dump_enc ] && rm -r ~/.secure_dump_enc ~/secure_dump
  mkdir -p ~/.secure_dump_enc ~/.secure_dump
  head -c 10 /dev/urandom | base64 | CRYFS_FRONTEND=noninteractive cryfs --allow-replaced-filesystem ~/.secure_dump_enc ~/secure_dump
fi
"
    echo ""
    echo "Maybe I'll migrate the setup-secure-dump script rely on them at some point :)"
    echo ""
    echo "If you really insist on using this script, pass the parameter --i-really-want-to"
    exit 0
fi

MOUNT_POINT="${KW_ARGS['-m']-$HOME/secure_dump}"
MOUNT_POINT="${KW_ARGS['--mountpoint']-$MOUNT_POINT}"
CONTAINER="${KW_ARGS['-c']-$HOME/secure_dump.img}"
CONTAINER="${KW_ARGS['--container']-$CONTAINER}"
SIZE="${KW_ARGS['-s']-1G}"
SIZE="${KW_ARGS['--size']-$SIZE}"

if [[ "${KW_ARGS['--delete']-${KW_ARGS['-d']}}" == "true" ]]
then
    echo "The existing container '$CONTAINER' will be deleted! Any data still saved in it will be lost!"
    if [[ ! -e "${CONTAINER}" ]]
    then
        echo "ERROR: '${CONTAINER}' could not be found! Exiting..."
	exit 4
    fi
    echo "To proceed, type $(basename ${CONTAINER^^})"
    read inp
    if [[ "$inp" != "$(basename ${CONTAINER^^})" ]]
    then
        echo "Exiting (user abort)..."
	exit 1
    fi

    set -e
    mount | grep "${CONTAINER}" > /dev/null && umount "${CONTAINER}"
    sudo sed -i "s|^.*${CONTAINER}.*$||g" /etc/crypttab
    sudo sed -i "s|^.*${CONTAINER}.*$||g" /etc/fstab
    rm "${CONTAINER}"

    echo "Secure dump '${CONTAINER}' has been deleted successfully."

    exit 0
fi


echo "We will create a secure dump crypto-container at '${MOUNT_POINT}' from container image '$CONTAINER' of size $SIZE."
echo "Proceed? (y/N)"
read choice
if [[ "$choice" != "y" ]] && [[ "$choice" != "Y" ]]
then
    echo "Exiting (user abort)..."
    exit 1
fi

if [[ ! -d "$MOUNT_POINT" ]]
then
    mkdir -p "$MOUNT_POINT"
elif [[ -n "$(ls -A "${MOUNT_POINT}")" ]]
then
    echo "ERROR: Mount point '${MOUNT_POINT}' exists and is not an empty directory. Exiting..."
    exit 2
fi

echo "Creating secure dump container image..."
if [[ -f "$CONTAINER" ]]
then
    echo "ERROR: Container file '$CONTAINER' already exists! Exiting..."
    exit 3
fi

dd if=/dev/zero of="${CONTAINER}" bs=1 count=0 seek="${SIZE}"
echo "done."
echo ""

USR_HOME="$HOME"
USR="$(id -un)"
USR_ID="$(id -u)"

SD_ID=1

echo "Consequently, the auto mounting of the encrypted container will be set up. Please provide your password if asked."

anytab_comment="### Secure Dump containers"

if [[ -z "$(grep "$anytab_comment" /etc/crypttab)" ]]
then
    echo "" | sudo tee -a /etc/crypttab > /dev/null
    echo "$anytab_comment" | sudo tee -a /etc/crypttab > /dev/null
    echo "" | sudo tee -a /etc/crypttab > /dev/null
fi

if [[ -z "$(grep "$anytab_comment" /etc/fstab)" ]]
then
    echo "" | sudo tee -a /etc/fstab > /dev/null
    echo "$anytab_comment" | sudo tee -a /etc/fstab > /dev/null
    echo "" | sudo tee -a /etc/fstab > /dev/null
fi

while [[ -n "$(grep "crypt_${USR_ID}_${SD_ID}_secure_dump" /etc/crypttab)" ]];
do
    echo "crypt_${USR_ID}_${SD_ID}_secure_dump already exists in /etc/crypttab; Attempting crypt_${USR_ID}_$(( ${SD_ID} + 1 ))_secure_dump..."
    SD_ID="$(( $SD_ID + 1 ))"
done

echo ""
echo "Setting up /etc/crypttab:"
echo "crypt_${USR_ID}_${SD_ID}_secure_dump ${CONTAINER} /dev/urandom tmp" | sudo tee -a /etc/crypttab
echo ""
echo "Setting up /etc/fstab:"
echo "/dev/mapper/crypt_${USR_ID}_${SD_ID}_secure_dump ${MOUNT_POINT} ext2 defaults 0 2" | sudo tee -a /etc/fstab

echo ""
echo "You're all set up. Upon next reboot, your secure dump container will be mounted at $MOUNT_POINT."
