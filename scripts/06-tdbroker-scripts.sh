# shellcheck shell=bash

# get current path of script. Thus we can call the script from everywhere.
SCRIPTPATH=$(dirname "$(readlink -f "$0")")

mkdir -p "$SCRIPTPATH/../embedded-files/lib/functions" || exit 42
cp "$SCRIPTPATH/../store/tunneldigger.sh" "$SCRIPTPATH/../embedded-files/lib/functions/tunneldigger.sh" || exit 42

mkdir -p "$SCRIPTPATH/../embedded-files/usr/lib/tunneldigger-broker/hooks" || exit 42
cp "$SCRIPTPATH/../store/hook-setup" "$SCRIPTPATH/../embedded-files/usr/lib/tunneldigger-broker/hooks/setup" || exit 42
cp "$SCRIPTPATH/../store/hook-mtu-changed" "$SCRIPTPATH/../embedded-files/usr/lib/tunneldigger-broker/hooks/mtu-changed" || exit 42
