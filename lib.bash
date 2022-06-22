#################
#   FUNCTIONS   #
#################

function build_router_db {
    # load the table-of-hardware from openwrt project, to get further information on router,
    # like i.e. flash-size
    printf "loading OpenWrt ToH...\n"

    wget -q "$OPENWRT_TOH" -O "$BUILTER_DIR/build/toh.gz"
    gunzip "$BUILTER_DIR/build/toh.gz"

    echo -e '.separator "\t"\n.import '"$BUILTER_DIR/build/toh"' toh' | sqlite3 "$BUILTER_DIR/build/toh.db"
    printf "\tdone.\n"
}

function request_router_from_db {
    local board="$1"
    local response

    response=$(
        sqlite3 -batch "$BUILTER_DIR/build/toh.db" <<EOF
SELECT
    brand, model, version, flashmb, rammb
FROM
    toh
WHERE
    firmwareopenwrtinstallurl LIKE '%$board%' OR
    firmwareopenwrtupgradeurl LIKE '%$board%' OR
    firmwareopenwrtsnapshotinstallurl LIKE '%$board%' OR
    firmwareopenwrtsnapshotupgradeurl LIKE '%$board%';
EOF
    )
    # sometimes different routers share the same image
    # like UniFi AC Mesh and UniFi AC Mesh Pro. Ensure to only
    # return one dataset and take the first one then.
    echo "$response" | head -n1
}

function patch_if_needed() {
    # check if a patch has already been applied (i.e. it's been merged upstream (for some versions))
    # and apply it only if it has not
    patch -f -s -R --dry-run -p${2:-1} -i "$1" >/dev/null ||
        patch -f -p${2:-1} -i "$1"
}

function patch_buildsystem() {
    # applies some patches to the buildsystem to allow us building falter in our way.

    # patch json-info, so that it will contain every image, not just the last one
    patch_if_needed ../../patches/append_new_images_overview_json.patch
    # fix patch at building mikrotik devices. prepones https://github.com/openwrt/openwrt/pull/3262
    patch_if_needed ../../patches/workaround-kernel2minor-path-length-limitation.patch 2
}

function derive_underlying_openwrt_version {
    # OpenWrt-Version from freifunk-release file could be something like
    # '19.07-SNAPSHOT'. But we have only packagelists for 19.07... Solve that.
    regex="^[0-9][0-9].[0-9][0-9]"
    if [[ $1 =~ $regex ]]; then
        echo $(echo $1 | cut -c 1-5)
    else
        echo "snapshot"
    fi
}

function read_packageset {
    local PACKAGE_SET_PATH=$1
    # read packageset, while removing comments, empty lines and newlines
    PACKAGE_SET=$(cat "$PACKAGE_SET_PATH" | sed -e '/^#/d; /^[[:space:]]*$/d' | tr '\n' ' ')
    if [ $? != 0 ]; then
        echo "failed to read packageset. Did you give a correct path?"
        exit 2
    fi
}

function fetch_subdirs {
    URL=$1
    curl -s "$URL" | grep href | grep -v 'snapshots\|releases' | awk -F'"' '{print $4}'
}

function is_wave1_device {
    # detect, if a device has wave1-chipset by its firmware
    local profile=$1
    DEVICE_PACKAGES=$(make info | grep "$profile:" -A 2 | tail -n1 | cut -d':' -f2)
    if [[ "$DEVICE_PACKAGES" =~ ath10k-firmware-qca988x || "$DEVICE_PACKAGES" =~ ath10k-firmware-qca9887 ]]; then
        subsitute_ct_driver "$DEVICE_PACKAGES"
    else
        PACKAGE_SET_DEVICE="$PACKAGE_SET"
    fi
}

function subsitute_ct_driver {
    # generate a packagelist with ct-drivers/firmware substituted by normal one
    local DEVICE_PACKAGES="$@"
    printf "wave1 chipset detected...\n"
    printf "\tchange firmware and drivers in packagelist to non-ct counterparts...\n"
    PACKAGE_SET_DEVICE=$(echo "$PACKAGE_SET"" $DEVICE_PACKAGES" | sed -e 's/ath10k-firmware-qca988x-ct/ath10k-firmware-qca988x -ath10k-firmware-qca988x-ct/g; s/ath10k-firmware-qca9887-ct/ath10k-firmware-qca9887 -ath10k-firmware-qca9887-ct/g; s/kmod-ath10k-ct/kmod-ath10k -kmod-ath10k-ct/g')
    printf "\tdone.\n"
}

function is_8MiB_flash_device {
    # remove some packages to keep the image-size quite below 8MiB
    local profile="$1"
    local DEVICE_PACKAGES=$(echo "$@" | cut -d' ' -f 2-)
    local flash

    flash=$(request_router_from_db "$profile" | cut -d'|' -f 4)

    # fail on purpose, if field didn't contain integer only
    # enforce 8MiB-List, if Router was specified in override-list
    if [ "$flash" -le 8 ] || [[ $OVERRIDE_TO_8MiB == *$profile* ]]; then
        printf "Board has 8MiB flash only. Removing some packages...\n"

        for P in $OMIT_LIST_8MiB; do
            PACKAGE_SET_DEVICE=$(echo "$PACKAGE_SET_DEVICE" | sed -e "s|$P||g")
        done
        printf "\tdone.\n"
    fi
}

function is_32MiB_RAM_device {
    echo "is_32MiB_RAM_device: Not implemented now"
    exit 42
}

function modify_packagelist {
    local profile="$1"

    # $PACKAGE_SET and $PACKAGE_SET_DEVICE are global variables holding the
    # original and the per device modified packagelist. They get modified by the
    # functions directly
    is_wave1_device "$profile"
    is_8MiB_flash_device "$profile" "$PACKAGE_SET_DEVICE"
}

function derive_branch_from_url {
    URL=$1
    RELEASE_TYPE=$(echo "$URL" | awk -F'/' '{print $4}')
    case $RELEASE_TYPE in
    releases)
        echo "$URL" | awk -F'/' '{print $5}' | cut -d. -f1-2
        ;;
    snapshots)
        echo snapshot
        ;;
    esac
}

function generate_embedded_files {
    FALTERBRANCH="$1"
    local url="$2"
    local fingerprint="$3"
    # call scripts to generate dynamic data in embedded files
    local TARGET=$(echo "$IMAGE_BUILDER_URL" | cut -d'/' -f 7)
    local SUBTARGET=$(echo "$IMAGE_BUILDER_URL" | cut -d'/' -f 8)

    local OPENWRT_BASE=$(echo "$IMAGE_BUILDER_URL" | cut -d'/' -f 5)

    # Get the FREIFUNK_RELEASE variable from the falter feed
    # located in the falter-common package.
    [ "snapshot" == "$FALTERBRANCH" ] && FALTERBRANCH="master"
    [ $FALTERBRANCH != "master" ] && FALTERBRANCH="openwrt-$PARSER_OWT"

    # clear out any old embedded_files
    rm -rf ../../embedded-files/*

    ../../scripts/01-generate_banner.sh "$FREIFUNK_RELEASE" "$TARGET" "$SUBTARGET" "$FREIFUNK_REVISION" ||
        {
            echo "01-generate_banner.sh failed..."
            exit 1
        }
    ../../scripts/02-favicon.sh || {
        echo "02-favicon.sh failed..."
        exit 1
    }
    ../../scripts/03-luci-footer.sh "$FREIFUNK_RELEASE" "$TARGET" "$SUBTARGET" "$FALTERBRANCH" "$FREIFUNK_REVISION" ||
        {
            echo "03-luci-footer.sh failed..."
            exit 1
        }
    export REPO # export repo line to inject into images. contains whitespace...
    ../../scripts/04-include-falter-feed.sh "$url" "$fingerprint" || {
        echo "04-include-falter-feed.sh failed..."
        exit 1
    }
    ../../scripts/05-olsrd-init-for-21-02-0.sh "$OPENWRT_BASE" || {
        echo "05-olsrd-init-for-21-02-0.sh failed..."
        exit 1
    }
    ../../scripts/06-luci-base-networkjs.sh "$OPENWRT_BASE" || {
        echo "06-luci-base-networkjs.sh failed..."
        exit 1
    }
}
