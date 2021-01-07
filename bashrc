BASH_UTILS_PATH="$(dirname $0)"

mounts() {
    df -x squashfs $@
}

apt-install-auto() {
  "${BASH_UTILS_PATH}/apt-install-auto.sh" $@
}

# gcp subcommand

gcp() {
  "gcp__$1" "${@:2}"
}

gcp__collect-bucket-permissions() {
  "${BASH_UTILS_PATH}/collect-bucket-permissions.sh" $@
}
