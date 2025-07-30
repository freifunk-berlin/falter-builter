#!/usr/bin/env bash

# shellcheck disable=SC2015

function usage() {
    local v="$1"
    local t="$2"

    echo "usage: build/build.sh <version> <target> <profile> [<destination>]"
    echo
    echo "versions and release branches:"
    echo "  snapshot => snapshot"
    echo "  1.5.x => 1.5.0-snapshot"
    echo "  1.4.x => 1.4.0-snapshot"
    echo "  1.3.x => 1.3.0-snapshot"
    echo "  1.2.x => 1.2.3-snapshot"
    echo "  testbuildbot => testbuildbot"
    echo "  anything else => snapshot"
    echo
    echo "target names:"
    if [ -n "$v" ]; then
        for vt in $(cat "$rootdir/build/targets-$v.txt" | grep -v '#' | grep . | cut -d' ' -f2- | xargs -n1 echo | sort); do
            echo -n "  $vt"
        done
        echo
    else
        echo "  run build/build.sh with a version to see available target names"
    fi
    echo
    echo "profile names:"
    if [ -n "$t" ]; then
        echo -n "  all"
        (
            cd "$rootdir/tmp/$orelease/$target"
            list=$(make info |& sed -n 's/\(^[a-zA-Z0-9_-]*\)\:$/\1/p' | sort || true)
            for p in $list; do
                echo -n "  $p"
            done
            echo
        )
    else
        echo "  run build/build.sh with a version and target name to see available device profiles"
    fi
    echo
    echo "destination:"
    echo "  path to a writable directory where image files will end up."
    echo "  default: ./out"
    echo
    echo "FALTER_VARIANT env variable:"
    echo "  chooses the packageset variant. (deprecated)"
    echo "  default: tunneldigger"
    echo
    echo "FALTER_FEED env variable:"
    echo "  customizes the falter package feed."
    echo "  default: https://firmware.berlin.freifunk.net/feed/<branch>/packages/<arch>/falter"
    echo "  opkg example: file:///tmp/falter-packages/out/main/x86_64/falter"
    echo "  apk example: file:///tmp/falter-packages/out/main/x86_64/falter/packages.adb"
    echo
    echo "FALTER_FEEDKEY env variable:"
    echo "  specifies an APK signing key for a custom package feed."
    echo "  apk example: /tmp/falter-packages/out/main/x86_64/public-key.pem"
    echo
    exit 1
}

rootdir=$(pwd)

[ -n "$1" ] && fversion="$1" || usage >&2

# map falter's versioning to openwrt's release branches
orelease="snapshot"
frelease="snapshot"
[[ "$fversion" =~ ^1\.5\. ]] && orelease="24.10-SNAPSHOT" && frelease="1.5.0-snapshot"
[[ "$fversion" =~ ^1\.4\. ]] && orelease="23.05-SNAPSHOT" && frelease="1.4.0-snapshot"
[[ "$fversion" =~ ^1\.3\. ]] && orelease="22.03-SNAPSHOT" && frelease="1.3.0-snapshot"
[[ "$fversion" =~ ^1\.2\. ]] && orelease="21.02.7" && frelease="1.2.3-snapshot"
[[ "$fversion" =~ ^testbuildbot ]] && orelease="snapshot" && frelease="testbuildbot"

[ -n "$2" ] && target="$2" || usage "$frelease" >&2
[ -n "$4" ] && dest="$4" || dest="./out"

variant="tunneldigger"
[ -z "$FALTER_VARIANT" ] || variant="$FALTER_VARIANT"
feed=""
[ -z "$FALTER_FEED" ] || feed="$FALTER_FEED"
feedkey=""
[ -z "$FALTER_FEEDKEY" ] || feedkey="$FALTER_FEEDKEY"

set -o pipefail
set -e
set -x

frevision=$(git rev-parse --short HEAD)

if [ -z "$FALTER_MIRROR" ] ; then
  owmirror="https://downloads.openwrt.org"
  fmirror="https://firmware.berlin.freifunk.net"
else
  owmirror="$FALTER_MIRROR/downloads.openwrt.org"
  fmirror="$FALTER_MIRROR/firmware.berlin.freifunk.net"
fi

# our opkg signing key (used by buildbot to sign the package feed)
fkey="RWRhoHijhAjnECRwgLkBfnA2rgHtgVNmDPJmFfIhGDxbK8vIFxkiZ8iF"
fkeyfp="61a078a38408e710"

destdir="$dest/$fversion/$variant/$target"
mkdir -p "$destdir"
rm -rf "$destdir/faillogs"

ibdir="./tmp/$orelease/$target"

wget -N -P ./tmp/dl "$fmirror/openwrt-table-of-hardware.csv"
echo -e '.separator "\t"\n.import tmp/dl/openwrt-table-of-hardware.csv toh' | sqlite3 tmp/toh.db

packageset="$(cat "packageset/$(echo "$fversion" | cut -d'-' -f1)/$variant.txt" | grep -vP '^#' | xargs echo -n)"

(
    # download and extract imagebuilder tarball
    # TODO: supper custom imagebuilder url
    dlurl="$owmirror/releases/$orelease/targets"
    [ "x$orelease" == "xsnapshot" ] && dlurl="$owmirror/snapshots/targets"
    ibfile=$(wget -q -O - "$dlurl/$target/sha256sums" | cut -d '*' -f 2 | grep -i openwrt-imagebuilder-)
    mkdir -p "./tmp/dl/"
    wget -nv -N -P ./tmp/dl "$dlurl/$target/$ibfile"
    rm -rf "$ibdir"
    mkdir -p "$ibdir"
    tar -x -C "$ibdir" --strip-components=1 -f "./tmp/dl/$ibfile"

    # let's get to work
    cd "$ibdir"
    mkdir -p "bin/targets/$target/faillogs"
    mkdir -p embedded-files/etc

    # device profile help text, late because we need the extracted imagebuilder for that
    [ -n "$3" ] && profile="$3" || (
        set +x
        usage "$frelease" "$target"
    )

    # falter package feed, APK for snapshot, OPKG for older branches
    arch="$(grep CONFIG_TARGET_ARCH_PACKAGES .config | cut -d'=' -f 2 | tr -d '"')"
    if [ "x$orelease" = "xsnapshot" ]; then

        # install falter signing key, regardless of feed choice
        apkdir="embedded-files/etc/apk"
        mkdir -p "$apkdir/keys" "$apkdir/repositories.d"
        cat <<EOF1 >keys/falter.snapshot.pem
-----BEGIN PUBLIC KEY-----
MFYwEAYHKoZIzj0CAQYFK4EEAAoDQgAEE1NSmLpdMjXJpDQki9ziqW3Ve0aIX99t
uAc1Yn5TexwhBhHsGxUxICHS63pDXYj9xg1AZHlvbEnFrBNrsdjJQQ==
-----END PUBLIC KEY-----
EOF1
        cp -av keys/falter.snapshot.pem "$apkdir/keys/"

        # custom feed vs. official falter feed
        if [ -n "$feed" ]; then
            echo "$feed" >>repositories
            echo "$feed" >>"$apkdir/repositories.d/falter.list"
            cp -av "$feedkey" keys/falter.custom.pem
            cp -av "$feedkey" "$apkdir/keys/falter.custom.pem"
        else
            adburl="$fmirror/feed/$frelease/packages/$arch/falter/packages.adb"
            echo "$adburl" >>repositories
            echo "$adburl" >"$apkdir/repositories.d/falter.list"
        fi

        if [ -n "$FALTER_MIRROR" ] ; then
            sed -i 's#https://downloads.openwrt.org#'"$owmirror"'#g' repositories
        fi

        sed -i 's#$(APK) add#echo $(APK) ; $(APK) --version ; $(APK) add#g' Makefile
    else
        # install falter signing key, regardless of feed choice
        opkgdir="embedded-files/etc/opkg"
        mkdir -p "$opkgdir/keys"
        {
            echo "untrusted comment: Falter OPKG Key 2024"
            echo "$fkey"
        } >"keys/$fkeyfp"
        cp -av "keys/$fkeyfp" "$opkgdir/keys/"

        # custom feed vs. official falter feed
        if [ -n "$feed" ]; then
            sed -i 's/option check_signature//g' repositories.conf
            echo "src/gz falter $feed" >>repositories.conf
            echo "src/gz falter $feed" >>"$opkgdir/customfeeds.conf"
        else
            feedurl="$fmirror/feed/$frelease/packages/$arch/falter"
            echo "src/gz falter $feedurl" >>repositories.conf
            echo "src/gz falter $feedurl" >>"$opkgdir/customfeeds.conf"
        fi

        if [ -n "$FALTER_MIRROR" ] ; then
            sed -i 's#https://downloads.openwrt.org#'"$owmirror"'#g' repositories.conf
        fi
    fi

    # /etc/freifunk_release
    {
        echo "FREIFUNK_DISTRIB_ID='Freifunk Falter'"
        echo "FREIFUNK_RELEASE='$fversion'"
        echo "FREIFUNK_REVISION='$frevision'"
        echo "FREIFUNK_VARIANT='$variant'"
    } >embedded-files/etc/freifunk_release

    # /etc/banner
    # TODO: replace with a dynamic banner via /etc/profile.d
    cat <<EOF >embedded-files/etc/banner
  _____        _  __             _
 |  ___|      (_)/ _|           | |
 | |_ _ __ ___ _| |_ _   _ _ __ | | __
 |  _| '__/ _ \ |  _| | | | '_ \| |/ /
 | | | | |  __/ | | | |_| | | | |   <
 \_| |_|  \___|_|_|  \__,_|_| |_|_|\_\

 Falter $fversion ($frevision) $target
 https://wiki.freifunk.net/Berlin:Firmware
 https://github.com/freifunk-berlin/falter-packages
 -----------------------------------------------------

 If you find bugs please report them at:

   https://github.com/freifunk-berlin/falter-packages/issues/

 For questions write a mail to <berlin@berlin.freifunk.net>
 or check https://berlin.freifunk.net/contact for our weekly meetings.
EOF

    # luci footer template (ucode since 23.05, html before)
    # TODO: replace with a luci library that provides falter info to templates
    if [[ "$orelease" =~ ^(19|21|22)\. ]]; then
        d="embedded-files/usr/lib/lua/luci/view/themes/bootstrap"
        mkdir -p "$d"
        cp "$rootdir/store/footer.htm" "$d/"
        sed -i "/Powered by.*/a \ \ \ \ <br><a href=\"https://berlin.freifunk.net\">Falter $fversion ($frevision)</a>" "$d/footer.htm"
    else
        d="embedded-files/usr/share/ucode/luci/template/themes/bootstrap"
        mkdir -p "$d"
        cp "$rootdir/store/footer.ut" "$d/"
        sed -i "s|{{ entityencode(version.disturl ?? '#', true) }}|https://berlin.freifunk.net|g" "$d/footer.ut"
        sed -i "s|{{ version.distname }} {{ version.distversion }} ({{ version.distrevision }})|Falter $fversion ($frevision)|g" "$d/footer.ut"
    fi

    # luci favicon
    d="embedded-files/www/luci-static/bootstrap/"
    mkdir -p "$d"
    cp "$rootdir/store/favicon.png" "$d/"

    # go over all devices and build them
    profilelist=$(make info | sed -n 's/\(^[a-zA-Z0-9_-]*\)\:$/\1/p' | sort || true)
    echo -n "building profiles:"
    echo "$profilelist" | xargs echo -n "  "
    echo
    for p in $profilelist; do

        # skip if device profile was set and it's not this device
        if [ "x$profile" != "xall" ] && [ "x$profile" != "x$p" ]; then
            continue
        fi

        # subshell because we save the device build log if it fails
        (
            # customize image based on device quirks (see below)
            packages="$packageset"
            info="$(echo "SELECT flashmb, rammb FROM toh WHERE firmwareopenwrtinstallurl LIKE '%$p%' OR firmwareopenwrtupgradeurl LIKE '%$p%' OR firmwareopenwrtsnapshotupgradeurl LIKE '%$p%' OR firmwareopenwrtsnapshotupgradeurl LIKE '%$p%' LIMIT 1" | sqlite3 -batch "$rootdir/tmp/toh.db")"

            # devices with <= 8 MB disk space
            smallflash=false
            flashmb="$(echo "$info" | cut -d'|' -f 1 | sed -E 's/[^0-9]*([0-9]+)[^0-9]*.*/\1/')"
            if [ -n "$flashmb" ] && [ "$flashmb" -le 8 ]; then
                smallflash=true
            fi

            # table of hardware lists flash chip capacity, not usable image space.
            # some 16 MB devices with A/B partition setup need to be forced to 8 MB.
            if [[ "$p" =~ ubnt_unifiac|ubnt_unifi-ap|ubnt_usw-flex ]]; then
                smallflash=true
            fi

            if $smallflash; then
                packages="-falter-berlin-service-registrar -luci-app-falter-service-registrar -luci-i18n-falter-service-registrar-de $packages"
                packages="-luci-app-statistics -luci-i18n-statistics-de -collectd-mod-rrdtool $packages"
                packages="-tcpdump-mini -mtr -iperf3 -tmux -vnstat $packages"
            fi

            # devices with <= 32 MB RAM
            rammb="$(echo "$info" | cut -d'|' -f 2 | sed -E 's/[^0-9]*([0-9]+)[^0-9]*.*/\1/')"
            if [ -n "$rammb" ] && [ "$rammb" -le 32 ]; then
                packages="zram-swap $packages"
            fi

            # qualcomm wave1 devices shouldn't use the CT/CandelaTech wifi driver
            devpkgs="$(make info | grep "$p:" -A 2 | tail -n1 | cut -d':' -f2)"
            if [[ "$devpkgs" =~ ath10k-firmware-qca9887 ]]; then
                packages="kmod-ath10k ath10k-firmware-qca9887 -kmod-ath10k-ct -ath10k-firmware-qca9887-ct -kmod-ath10k-ct-smallbuffers $packages"
            fi
            if [[ "$devpkgs" =~ ath10k-firmware-qca988x ]]; then
                packages=" kmod-ath10k ath10k-firmware-qca988x -kmod-ath10k-ct -ath10k-firmware-qca988x-ct -kmod-ath10k-ct-smallbuffers $packages"
            fi

            # broken kernel module (6/2024)
            if [ "x$target" = "xx86/64" ]; then
                packages=" -kmod-dwmac-intel $packages"
            fi

            # build images for this device
            make image PROFILE="$p" PACKAGES="$packages" FILES=embedded-files EXTRA_IMAGE_NAME="freifunk-falter-$fversion" || true
        ) \
            |& tee "bin/targets/$target/faillogs/$p.log" >&2

        # if build resulted in image files, we can delete the log
        cnt="$(find "bin/targets/$target/" -iname "*$p*.bin" -or -iname "*$p*.img" -or -iname "*$p*.gz" -or -iname "*$p*.ubi" -or -iname "*Image*" | wc -l)"
        if [ "$cnt" -gt 0 ]; then
            rm -v "bin/targets/$target/faillogs/$p.log"
        fi
    done
) \
    |& tee "$destdir/build.log" >&2

find "$ibdir/bin/targets/$target" \( -name '*.bin' -or -name '*.img' -or -name '*.gz' -or -name '*.ubi' -or -name '*Image*' -or -name 'profiles.json' \) -exec mv -v '{}' "$destdir/" \;
mv "$ibdir/bin/targets/$target/faillogs" "$destdir/"

echo "Done."
