#!/usr/bin/env bash

print_help() {
    echo "USAGE:"
    echo "  setup_secure_dump [OPTIONS] [mount_point [container]]"
    echo "  mount_point:"
    echo "      The directory to mount the container to (must be empty or nonexistent)"
    echo "  container:"
    echo "      The location where the container image should be created (must not exist)"
    echo ""
    echo "  Options:"
    echo "      -h, --help Print this message"
    echo "      -s, --size The size of the container (e.g. '1G', '500MB')"
}

expected=""
arg_mount_point=""
arg_container=""
arg_size=""

for arg in "$@"
do
    if [ "$expected" == "size" ]
    then
        arg_size="$arg"
    fi

    if [ ! -z "$expected" ]
    then
        expected=""
        continue
    elif [ "$arg" == "--size" ] || [ "$arg" == "-s" ]
    then
        expected="size"
    elif [ "$arg" == "--help" ] || [ "$arg" == "-h" ]
    then
        print_help
        exit 0
    elif [ -z "$arg_mount_point" ]
    then
        arg_mount_point="$arg"
    elif [ -z "$arg_container" ]
    then
        arg_container="$arg"
    fi
done

readonly MOUNT_POINT="${arg_mount_point:-$HOME/secure_dump}"
readonly CONTAINER="${arg_container:-$HOME/secure_dump.img}"
readonly SIZE="${arg_size:-1G}"


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

echo "Consequently, the auto mounting of the encrypted container will be set up. Please provide your password if asked."

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
