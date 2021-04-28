# inject the feed line into the file customfeed.conf and
# include that file via embedded-files into images.

# get current path of script. Thus we can call the script from everywhere.
SCRIPTPATH=$(dirname $(readlink -f "$0"))

mkdir -p "$SCRIPTPATH/../embedded-files/etc/opkg/keys"

printf \
"
# add your custom package feeds here
#
# src/gz example_feed_name http://www.example.com/path/to/files
" > "$SCRIPTPATH/../embedded-files/etc/opkg/customfeeds.conf"

cat "$FALTER_FEEDS" | while read REPO_BASE ; do
    KEY="${REPO_BASE%% *}"
    REPO_BASE="${REPO_BASE#* }"
    REPO_NAME="${REPO_BASE#* }"
    REPO_NAME="${REPO_NAME%% *}"
    REPO_URL="${REPO_BASE##* }"
    if [[ "$KEY" != "" ]] && [[ $KEY != \#* ]]; then
        echo REPO $KEY: $REPO_BASE
        REPO="${REPO_BASE}${FALTER_REPO_ADD}${PARSER_FALTER_VERSION}/packages/$INSTR_SET/${REPO_NAME}"
        echo "injecting repo line: $REPO"
        echo "$REPO" >> repositories.conf

        URL="${REPO_URL}packagefeed_master.pub"
        curl "$URL" > "$SCRIPTPATH/../embedded-files/etc/opkg/keys/$KEY"

        REPO_HTTP=$(echo $REPO | sed -e 's/https/http/g')

        echo $REPO_HTTP >> "$SCRIPTPATH/../embedded-files/etc/opkg/customfeeds.conf"
    fi
done
