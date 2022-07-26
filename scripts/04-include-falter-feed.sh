# shellcheck shell=bash
# shellcheck disable=SC2059

# inject the feed line into the file customfeed.conf and
# include that file via embedded-files into images.

# get current path of script. Thus we can call the script from everywhere.
SCRIPTPATH=$(dirname "$(readlink -f "$0")")
URL="$1"
FINGERPRINT="$2"

mkdir -p "$SCRIPTPATH/../embedded-files/etc/opkg/keys" || exit 42

# load package-key and post it to dir. keyname is keys fingerprint.
curl -s "$URL" >"$SCRIPTPATH/../embedded-files/etc/opkg/keys/$FINGERPRINT" || exit 42

REPO_HTTP=${REPO/https/http}

# We inherited $FALTER_REPO_BASE from caller whom exported it.
printf \
"
# add your custom package feeds here
#
# src/gz example_feed_name http://www.example.com/path/to/files
$REPO_HTTP
" > "$SCRIPTPATH/../embedded-files/etc/opkg/customfeeds.conf" || exit 42
