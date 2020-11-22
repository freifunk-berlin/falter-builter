VERSION="$1"
NICKNAME="$2"
TARGET="$3"
SUBTARGET="$4"
# get current path of script. Thus we can call the script from everywhere.
SCRIPTPATH=$(dirname $(readlink -f "$0"))

SRCFOOTER="https://raw.githubusercontent.com/openwrt/luci/master/themes/luci-theme-bootstrap/luasrc/view/themes/bootstrap/footer.htm"
FOOTERDIR="$SCRIPTPATH/../embedded-files/usr/lib/lua/luci/view/themes/bootstrap/"
mkdir -p $FOOTERDIR

wget -O $FOOTERDIR/footer.htm $SRCFOOTER

sed -i "/Powered by.*/a \ \ \ \ <br><a href=\"https://berlin.freifunk.net\">Freifunk Berlin</a> ($NICKNAME v$VERSION) $TARGET - $SUBTARGET" $FOOTERDIR/footer.htm 

