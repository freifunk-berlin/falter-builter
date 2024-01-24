# shellcheck shell=bash

# get current path of script. Thus we can call the script from everywhere.
SCRIPTPATH=$(dirname "$(readlink -f "$0")")

dir="$SCRIPTPATH/../embedded-files/etc"
mkdir -p "$dir" || exit 42

{
  echo "FREIFUNK_DISTRIB_ID='Freifunk Falter'"
  echo "FREIFUNK_RELEASE='$1'"
  echo "FREIFUNK_OPENWRT_BASE='$2'"
  echo "FREIFUNK_REVISION=''"
  echo "FREIFUNK_VARIANT='$3'"
} > "$dir/freifunk_release"
