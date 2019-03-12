#!/usr/bin/env bash

#
# Remove security checks from a VPN connection created by NetworkManager
# (in case you're forced to use a weak VPN certificate)
#

if [ "$EUID" -ne 0 ]
then
	echo "This command requires root permissions!"
	exit 1
fi

if [ -z "$1" ]
then
    echo "ERROR! Missing parameter: 'vpn-config-file' (as found in /etc/NetworkManager/system-connections)"
    exit 1
fi

sed -i -- 's/\[vpn\]/[vpn]\ntls-cipher=DEFAULT:@SECLEVEL=0\n/' /etc/NetworkManager/system-connections/${1?}
nmcli connection reload
