OPENWRT_BASE="$1"

# The change to network.js will be included in all future 21.02 and 19.07
# releases. Handle the exceptions here

[ "$OPENWRT_BASE" = "21.02.0" ] || [ "$OPENWRT_BASE" = "21.02.1" ] || exit

OPENWRT_LUCI_COMMITID="8bd4e78ff27c3e516b197f6b7500367d6672d68b"
SCRIPTPATH=$(dirname $(readlink -f "$0"))
INSTDIR="$SCRIPTPATH/../embedded-files/www/luci-static/resources"

mkdir -p $INSTDIR
wget -O $INSTDIR/network.js https://raw.githubusercontent.com/openwrt/luci/${OPENWRT_LUCI_COMMITID}/modules/luci-base/htdocs/luci-static/resources/network.js
chmod 644 $INSTDIR/network.js
