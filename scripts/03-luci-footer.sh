# shellcheck shell=bash

VERSION="$1"
TARGET="$2"
OPENWRT_BASE="$3"
REVISION="$4"
# get current path of script. Thus we can call the script from everywhere.
SCRIPTPATH=$(dirname "$(readlink -f "$0")")

if [ "$OPENWRT_BASE" = "openwrt-19.07" ] || [ "$OPENWRT_BASE" = "openwrt-21.02" ] || [ "$OPENWRT_BASE" = "openwrt-22.03" ]; then
    SRCFOOTER="https://raw.githubusercontent.com/openwrt/luci/${OPENWRT_BASE}/themes/luci-theme-bootstrap/luasrc/view/themes/bootstrap/footer.htm"

    FOOTERDIR="$SCRIPTPATH/../embedded-files/usr/lib/lua/luci/view/themes/bootstrap/"
    mkdir -p "$FOOTERDIR" || exit 42

    wget -q -P "$FOOTERDIR" "$SRCFOOTER" || exit 42
    sed -i "/Powered by.*/a \ \ \ \ <br><a href=\"https://berlin.freifunk.net\">Freifunk Berlin</a> (Falter v$VERSION - $REVISION) $TARGET" "$FOOTERDIR/footer.htm" || exit 42
else
    SRCFOOTER="https://raw.githubusercontent.com/openwrt/luci/${OPENWRT_BASE}/themes/luci-theme-bootstrap/ucode/template/themes/bootstrap/footer.ut"

    FOOTERDIR="$SCRIPTPATH/../embedded-files/usr/share/ucode/luci/template/themes/bootstrap/"
    mkdir -p "$FOOTERDIR" || exit 42
    wget -q -P "$FOOTERDIR" "$SRCFOOTER" || exit 42

    sed -i 's|{{ entityencode(version.disturl ?? .*, true) }}|https://berlin.freifunk.net|g' "$FOOTERDIR/footer.ut" || exit 42
    sed -i "s|{{ version.distname }} {{ version.distversion }} ({{ version.distrevision }})|(Falter v$VERSION - $REVISION) $TARGET|g" "$FOOTERDIR/footer.ut" || exit 42
fi
