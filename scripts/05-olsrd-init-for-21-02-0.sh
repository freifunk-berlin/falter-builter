OPENWRT_BASE="$1"

[ "$OPENWRT_BASE" != "21.02.0" ] && exit

OPENWRT_ROUTING_COMMITID="1fcda9dfa893ed5b06ce71f36f454cfec11092e5"
SCRIPTPATH=$(dirname $(readlink -f "$0"))
INITDIR="$SCRIPTPATH/../embedded-files/etc/init.d"

mkdir -p $INITDIR
wget -O $INITDIR/olsrd https://raw.githubusercontent.com/openwrt/routing/${OPENWRT_ROUTING_COMMITID}/olsrd/files/olsrd4.init
wget -O $INITDIR/olsrd6 https://raw.githubusercontent.com/openwrt/routing/${OPENWRT_ROUTING_COMMITID}/olsrd/files/olsrd6.init
