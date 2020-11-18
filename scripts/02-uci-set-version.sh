VERSION="$1"
# get current path of script. Thus we can call the script from everywhere.
SCRIPTPATH=$(dirname $(readlink -f "$0"))

mkdir -p "$SCRIPTPATH/../embedded-files/etc/uci-defaults/"

printf \
"#!/bin/sh

uci set system.@system[0].version='$VERSION'
if [ $? != '0' ] ; then
	exit 1
else 
	exit 0
fi

" > "$SCRIPTPATH/../embedded-files/etc/uci-defaults/099-set-freifunk-version.sh"
