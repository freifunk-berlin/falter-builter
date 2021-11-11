# get current path of script. Thus we can call the script from everywhere.
SCRIPTPATH=$(dirname $(readlink -f "$0"))

mkdir -p "$SCRIPTPATH/../embedded-files/www/luci-static/bootstrap"
cp "$SCRIPTPATH/../store/favicon.png" "$SCRIPTPATH/../embedded-files/www/luci-static/bootstrap"

