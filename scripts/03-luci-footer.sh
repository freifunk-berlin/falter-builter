# shellcheck shell=bash

VERSION="$1"
TARGET="$2"
SUBTARGET="$3"
OPENWRT_BASE="$4"
REVISION="$5"
# get current path of script. Thus we can call the script from everywhere.
SCRIPTPATH=$(dirname "$(readlink -f "$0")")

SRCFOOTER="https://raw.githubusercontent.com/openwrt/luci/${OPENWRT_BASE}/themes/luci-theme-bootstrap/luasrc/view/themes/bootstrap/footer.htm"
FOOTERDIR="$SCRIPTPATH/../embedded-files/usr/lib/lua/luci/view/themes/bootstrap/"
mkdir -p "$FOOTERDIR" || exit 42

wget -q -O "$FOOTERDIR/footer.htm" "$SRCFOOTER" || exit 42

sed -i "/Powered by.*/a \ \ \ \ <br><a href=\"https://berlin.freifunk.net\">Freifunk Berlin</a> ($NICKNAME v$VERSION - $REVISION) $TARGET - $SUBTARGET" "$FOOTERDIR/footer.htm" || exit 42
