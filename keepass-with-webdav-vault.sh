#!/usr/bin/env bash

#
# Script to mount a webdav directory via davfs (requires fstab entry!) and start keepass with 
# a vault in said directory subsequently
#


VAULT_PATH="/PATH/TO/YOUR/VAULT/AFTER/WEBDAV/MOUNT/"

umount "/media/keepass"
mount "/media/keepass"
sleep 1
flatpak run --file-forwarding org.keepassxc.KeePassXC @@ "$VAULT_PATH" @@
