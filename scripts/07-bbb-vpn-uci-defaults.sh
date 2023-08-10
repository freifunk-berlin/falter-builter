# shellcheck shell=bash

# get current path of script. Thus we can call the script from everywhere.
SCRIPTPATH=$(dirname "$(readlink -f "$0")")

mkdir -p "$SCRIPTPATH/../embedded-files/etc/uci-defaults" || exit 42
echo "/etc/init.d/olsrd6 stop; /etc/init.d/olsrd6 disable" > "$SCRIPTPATH/../embedded-files/etc/uci-defaults/999-disable-olsrd6" || exit 42
