VERSION="$1"
TARGET="$2"
SUBTARGET="$3"
REVISION="$4"
# get current path of script. Thus we can call the script from everywhere.
SCRIPTPATH=$(dirname $(readlink -f "$0"))

mkdir -p "$SCRIPTPATH/../embedded-files/etc/"

printf \
"  _____        _  __             _
 |  ___|      (_)/ _|           | |
 | |_ _ __ ___ _| |_ _   _ _ __ | | __
 |  _| '__/ _ \ |  _| | | | '_ \| |/ /
 | | | | |  __/ | | | |_| | | | |   <
 \_| |_|  \___|_|_|  \__,_|_| |_|_|\_\ 

 Firmware Berlin ($NICKNAME v$VERSION - $REVISION)
   $TARGET - $SUBTARGET
 https://wiki.freifunk.net/Berlin:Firmware
 https://github.com/Freifunk-Spalter/
 -----------------------------------------------------

 If you find bugs please report them at:

   https://github.com/Freifunk-Spalter/packages/issues/

 For questions write a mail to <berlin@berlin.freifunk.net>
 or check https://berlin.freifunk.net/contact for our weekly meetings.

" > "$SCRIPTPATH/../embedded-files/etc/banner"
