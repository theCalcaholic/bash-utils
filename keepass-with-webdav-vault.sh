#!/usr/bin/env bash

#
# Script to mount a network (e.g. sshfs/davfs) directory (requires fstab entry for /media/keepass!) and subsequently start keepass with 
# a vault in said directory
# Requires the flatpak version of KeepassXC to be installed!!!
#

VAULT_PATH="/PATH/TO/YOUR/VAULT/AFTER/WEBDAV/MOUNT/"

umount "/media/keepass"
mount "/media/keepass"
sleep 1
flatpak run --file-forwarding org.keepassxc.KeePassXC @@ "$VAULT_PATH" @@
