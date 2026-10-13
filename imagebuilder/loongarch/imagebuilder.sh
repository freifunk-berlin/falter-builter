#!/usr/bin/env bash

set -e
set -o pipefail

function usage() {
  echo "usage: imagebuilder/loongarch/imagebuilder.sh"
  echo
  exit 1
}

# [ -n "$1" ] && target="$1" || usage >&2
target="loongarch64/generic"

set -x

outdir="out/imagebuilder/loongarch/$target"
builddir="tmp/imagebuilder/loongarch"
# rm -rf "$builddir"
rm -rf "$builddir/bin" "$builddir/package/feeds"
# mkdir -p "$builddir"

(
  [ -d "$builddir" ] || git clone https://git.openwrt.org/openwrt/openwrt.git "$builddir"
  # git clone https://github.com/openwrt/openwrt.git "$builddir"
  # git clone /home/user/w/ow/openwrt "$builddir"
  cd "$builddir"
  # git checkout loongarch64-6.18
  git checkout .
  # git clean -fdx

  echo > .config

  cp feeds.conf.default feeds.conf
#   cat >> feeds.conf << 'EOF'
# src-git-full falter https://github.com/freifunk-berlin/falter-packages.git;main
# EOF
  cat >> feeds.conf << 'EOF'
src-link falter /home/user/w/ff/falter-packages
EOF
  ./scripts/feeds update -a
  ./scripts/feeds install -a

  make defconfig

  cat >> .config << 'EOF'
CONFIG_PACKAGE_apk-mbedtls=y
CONFIG_PACKAGE_base-files=y
CONFIG_PACKAGE_bgpdisco-plugin-nameservice=y
CONFIG_PACKAGE_bgpdisco=y
CONFIG_PACKAGE_bird3-babelpatch=y
CONFIG_PACKAGE_bird3c-babelpatch=y
CONFIG_PACKAGE_bird3cl-babelpatch=y
CONFIG_PACKAGE_busybox=y
CONFIG_PACKAGE_ca-bundle=y
CONFIG_PACKAGE_cgi-io=y
CONFIG_PACKAGE_collectd-mod-conntrack=y
CONFIG_PACKAGE_collectd-mod-cpu=y
CONFIG_PACKAGE_collectd-mod-dhcpleases=y
CONFIG_PACKAGE_collectd-mod-interface=y
CONFIG_PACKAGE_collectd-mod-iwinfo=y
CONFIG_PACKAGE_collectd-mod-load=y
CONFIG_PACKAGE_collectd-mod-memory=y
CONFIG_PACKAGE_collectd-mod-network=y
CONFIG_PACKAGE_collectd-mod-olsrd=y
CONFIG_PACKAGE_collectd-mod-ping=y
CONFIG_PACKAGE_collectd-mod-snmp=y
CONFIG_PACKAGE_collectd-mod-uptime=y
CONFIG_PACKAGE_collectd=y
CONFIG_PACKAGE_dnsmasq=y
CONFIG_PACKAGE_dropbear=y
CONFIG_PACKAGE_ethtool=y
CONFIG_PACKAGE_falter-berlin-owm-ucode=y
CONFIG_PACKAGE_falter-profiles=y
CONFIG_PACKAGE_firewall4=y
CONFIG_PACKAGE_fstools=y
CONFIG_PACKAGE_fwtool=y
CONFIG_PACKAGE_getrandom=y
CONFIG_PACKAGE_hostapd-common=y
CONFIG_PACKAGE_ip-bridge=y
CONFIG_PACKAGE_ip-tiny=y
CONFIG_PACKAGE_ip6tables-nft=y
CONFIG_PACKAGE_iperf3=y
CONFIG_PACKAGE_iptables-mod-ipopt=y
CONFIG_PACKAGE_iptables-nft=y
CONFIG_PACKAGE_irqbalance=y
CONFIG_PACKAGE_iw=y
CONFIG_PACKAGE_iwinfo=y
CONFIG_PACKAGE_jansson4=y
CONFIG_PACKAGE_jshn=y
CONFIG_PACKAGE_jsonfilter=y
CONFIG_PACKAGE_kmod-b43=y
CONFIG_PACKAGE_kmod-macvlan=y
CONFIG_PACKAGE_kmod-nft-bridge=y
CONFIG_PACKAGE_kmod-usb-ledtrig-usbport=y
CONFIG_PACKAGE_kmod-usb-ohci=y
CONFIG_PACKAGE_kmod-usb2=y
CONFIG_PACKAGE_libatomic1=y
CONFIG_PACKAGE_libc=y
CONFIG_PACKAGE_libevent2-core7=y
CONFIG_PACKAGE_libgcc1=y
CONFIG_PACKAGE_libiperf3=y
CONFIG_PACKAGE_libiptext-nft0=y
CONFIG_PACKAGE_libiptext0=y
CONFIG_PACKAGE_libiptext6=y
CONFIG_PACKAGE_libiwinfo-data=y
CONFIG_PACKAGE_libiwinfo-lua=y
CONFIG_PACKAGE_libjson-c5=y
CONFIG_PACKAGE_libltdl7=y
CONFIG_PACKAGE_liblua5.1.5=y
CONFIG_PACKAGE_liblucihttp-lua=y
CONFIG_PACKAGE_liblucihttp-ucode=y
CONFIG_PACKAGE_liblucihttp0=y
CONFIG_PACKAGE_libmbedtls21=y
CONFIG_PACKAGE_libmnl0=y
CONFIG_PACKAGE_libncurses6=y
CONFIG_PACKAGE_libnetsnmp-nossl=y
CONFIG_PACKAGE_libnftnl11=y
CONFIG_PACKAGE_libnl-tiny1=y
CONFIG_PACKAGE_libopenssl3=y
CONFIG_PACKAGE_liboping=y
CONFIG_PACKAGE_libpcap1=y
CONFIG_PACKAGE_libpci=y
CONFIG_PACKAGE_libpcre2=y
CONFIG_PACKAGE_libpthread=y
CONFIG_PACKAGE_libreadline8=y
CONFIG_PACKAGE_librt=y
CONFIG_PACKAGE_libstdcpp6=y
CONFIG_PACKAGE_libubus-lua=y
CONFIG_PACKAGE_libudebug=y
CONFIG_PACKAGE_libxtables12=y
CONFIG_PACKAGE_logd=y
CONFIG_PACKAGE_lua=y
CONFIG_PACKAGE_luci-app-olsr-services=y
CONFIG_PACKAGE_luci-app-olsr=y
CONFIG_PACKAGE_luci-base=y
CONFIG_PACKAGE_luci-compat=y
CONFIG_PACKAGE_luci-lib-base=y
CONFIG_PACKAGE_luci-lib-ip=y
CONFIG_PACKAGE_luci-lib-ipkg=y
CONFIG_PACKAGE_luci-lib-json=y
CONFIG_PACKAGE_luci-lib-jsonc=y
CONFIG_PACKAGE_luci-lib-nixio=y
CONFIG_PACKAGE_luci-lib-uqr=y
CONFIG_PACKAGE_luci-lua-runtime=y
CONFIG_PACKAGE_luci-mod-admin-full=y
CONFIG_PACKAGE_luci-mod-falter=y
CONFIG_PACKAGE_luci-mod-network=y
CONFIG_PACKAGE_luci-mod-status=y
CONFIG_PACKAGE_luci-mod-system=y
CONFIG_PACKAGE_luci-proto-ipv6=y
CONFIG_PACKAGE_luci-theme-bootstrap=y
CONFIG_PACKAGE_mtd=y
CONFIG_PACKAGE_mtr-nojson=y
CONFIG_PACKAGE_netifd=y
CONFIG_PACKAGE_nftables-json=y
CONFIG_PACKAGE_odhcp6c=y
CONFIG_PACKAGE_odhcpd-ipv6only=y
CONFIG_PACKAGE_olsrd-mod-arprefresh=y
CONFIG_PACKAGE_olsrd-mod-dyn-gw=y
CONFIG_PACKAGE_olsrd-mod-jsoninfo=y
CONFIG_PACKAGE_olsrd-mod-nameservice=y
CONFIG_PACKAGE_olsrd-mod-sgwdynspeed=y
CONFIG_PACKAGE_olsrd-mod-txtinfo=y
CONFIG_PACKAGE_olsrd-utils=y
CONFIG_PACKAGE_olsrd=y
CONFIG_PACKAGE_openssh-sftp-server=y
CONFIG_PACKAGE_openssh-sftp-server=y
CONFIG_PACKAGE_openwrt-keyring=y
CONFIG_PACKAGE_procd-seccomp=y
CONFIG_PACKAGE_procd-ujail=y
CONFIG_PACKAGE_procd=y
CONFIG_PACKAGE_protobuf-lite=y
CONFIG_PACKAGE_protobuf=y
CONFIG_PACKAGE_px5g-mbedtls=y
CONFIG_PACKAGE_rpcd-mod-file=y
CONFIG_PACKAGE_rpcd-mod-iwinfo=y
CONFIG_PACKAGE_rpcd-mod-luci=y
CONFIG_PACKAGE_rpcd-mod-rrdns=y
CONFIG_PACKAGE_rpcd-mod-ucode=y
CONFIG_PACKAGE_rpcd=y
CONFIG_PACKAGE_tcpdump-mini=y
CONFIG_PACKAGE_terminfo=y
CONFIG_PACKAGE_tmux=y
CONFIG_PACKAGE_tunspace=y
CONFIG_PACKAGE_ubi-utils=y
CONFIG_PACKAGE_uboot-envtools=y
CONFIG_PACKAGE_ubox=y
CONFIG_PACKAGE_ubus=y
CONFIG_PACKAGE_ubusd=y
CONFIG_PACKAGE_uci=y
CONFIG_PACKAGE_uclient-fetch=y
CONFIG_PACKAGE_ucode-mod-debug=y
CONFIG_PACKAGE_ucode-mod-digest=y
CONFIG_PACKAGE_ucode-mod-fs=y
CONFIG_PACKAGE_ucode-mod-html=y
CONFIG_PACKAGE_ucode-mod-log=y
CONFIG_PACKAGE_ucode-mod-lua=y
CONFIG_PACKAGE_ucode-mod-math=y
CONFIG_PACKAGE_ucode-mod-nl80211=y
CONFIG_PACKAGE_ucode-mod-resolv=y
CONFIG_PACKAGE_ucode-mod-rtnl=y
CONFIG_PACKAGE_ucode-mod-socket=y
CONFIG_PACKAGE_ucode-mod-struct=y
CONFIG_PACKAGE_ucode-mod-ubus=y
CONFIG_PACKAGE_ucode-mod-uci=y
CONFIG_PACKAGE_ucode-mod-uloop=y
CONFIG_PACKAGE_ucode-mod-wireguard=y
CONFIG_PACKAGE_ucode=y
CONFIG_PACKAGE_uhttpd-mod-ubus=y
CONFIG_PACKAGE_uhttpd=y
CONFIG_PACKAGE_urandom-seed=y
CONFIG_PACKAGE_urngd=y
CONFIG_PACKAGE_usign=y
CONFIG_PACKAGE_vnstat=y
CONFIG_PACKAGE_wifi-scripts=y
CONFIG_PACKAGE_wireguard-tools=y
CONFIG_PACKAGE_wireless-regdb=y
CONFIG_PACKAGE_wpad-basic-mbedtls=y
CONFIG_PACKAGE_xtables-nft=y
CONFIG_PACKAGE_zlib=y

CONFIG_PACKAGE_gdb=y
CONFIG_DEBUG=y
CONFIG_TARGET_ROOTFS_PARTSIZE=1024

CONFIG_PACKAGE_blkid=y
CONFIG_PACKAGE_e2fsprogs=y
CONFIG_PACKAGE_kmod-drm-amdgpu=y
CONFIG_PACKAGE_kmod-r8169=y
CONFIG_PACKAGE_partx-utils=y
CONFIG_PACKAGE_video-support=y

EOF

  cat >> .config << 'EOF'
CONFIG_EXPERIMENTAL=y
CONFIG_LINUX_6_18=y
CONFIG_TESTING_KERNEL=y
CONFIG_TARGET_ROOTFS_EXT4FS=y
EOF

#   cat >> .config << 'EOF'
# CONFIG_TARGET_mediatek=y
# CONFIG_TARGET_mediatek_mt7622=y
# CONFIG_TARGET_mediatek_mt7622_DEVICE_linksys_e8450-ubi=y
# EOF
  cat >> .config << 'EOF'
CONFIG_TARGET_loongarch64=y
CONFIG_TARGET_loongarch64_generic=y
CONFIG_TARGET_loongarch64_generic_generic=y
EOF

  cat >> .config << 'EOF'
CONFIG_IB=y
CONFIG_IB_STANDALONE=y
CONFIG_IMAGEOPT=y
EOF

  make defconfig

  make -j 24 STRIP=true
  # make -j 1 V=s
  # make package/mt76/compile V=s
)

mkdir -p "$outdir"
cp -av "$builddir/bin/targets/$target/"*imagebuilder* "$outdir/"
cp -av "$builddir/bin/targets/$target/"*.buildinfo "$outdir/"
