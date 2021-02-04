# inject the feed line into the file customfeed.conf and
# include that file via embedded-files into images.

# get current path of script. Thus we can call the script from everywhere.
SCRIPTPATH=$(dirname $(readlink -f "$0"))

mkdir -p "$SCRIPTPATH/../embedded-files/etc/opkg/keys"

# load package-key and post it to dir. keyname is keys fingerprint.
URL="https://buildbot.berlin.freifunk.net/buildbot/feed/packagefeed_master.pub"
curl "$URL" > "$SCRIPTPATH/../embedded-files/etc/opkg/keys/61a078a38408e710"

# We inherited $FALTER_REPO_BASE from caller whom exported it.
printf \
"
# add your custom package feeds here
#
# src/gz example_feed_name http://www.example.com/path/to/files
$REPO
" > "$SCRIPTPATH/../embedded-files/etc/opkg/customfeeds.conf"
