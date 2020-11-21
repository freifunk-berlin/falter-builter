VERSION="$1"
# get current path of script. Thus we can call the script from everywhere.
SCRIPTPATH=$(dirname $(readlink -f "$0"))

mkdir -p "$SCRIPTPATH/../embedded-files/etc/uci-defaults/"

printf \
"FREIFUNK_RELEASE='$VERSION'

" > "$SCRIPTPATH/../embedded-files/etc/freifunk_release"
