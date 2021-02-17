BASH_UTILS_PATH="$(dirname $BASH_SOURCE)"

mounts() {
    df -x squashfs $@
}

# gcp subcommand

#gcp() {
#  "gcp__$1" "${@:2}"
#}

#gcp__collect-bucket-permissions() {
#  "${BASH_UTILS_PATH}/collect-bucket-permissions.sh" $@
#}

