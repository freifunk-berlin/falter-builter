#!/usr/bin/env bash

set -e
set -o pipefail

function usage() {
  echo "usage: imagebuilder/mt76-testing/imagebuilder.sh <target>"
  echo
  echo "target names:"
  echo "    rampis/mt7621  mediatek/mt7622"
  echo
  exit 1
}

[ -n "$1" ] && target="$1" || usage >&2

set -x

outdir="out/imagebuilder/mt76-testing/$target"
builddir="tmp/imagebuilder/mt76-testing"
rm -rf "$builddir"
rm -rf "$builddir/bin"
# mkdir -p "$builddir"

(
  # [ -d "$builddir" ] || git clone https://git.openwrt.org/openwrt/openwrt.git "$builddir"
  [ -d "$builddir" ] || git clone https://github.com/pktpls/openwrt.git "$builddir"
  # git clone https://github.com/openwrt/openwrt.git "$builddir"
  # git clone /home/user/w/ow/openwrt "$builddir"
  cd "$builddir"
  git checkout pktpls-mt76
  git checkout .

#   git apply << 'EOF'
# diff --git a/package/kernel/mt76/Makefile b/package/kernel/mt76/Makefile
# index 070d0f3c2b..d95fd1bc67 100644
# --- a/package/kernel/mt76/Makefile
# +++ b/package/kernel/mt76/Makefile
# @@ -6,11 +6,11 @@ PKG_RELEASE=1
#  PKG_LICENSE:=GPLv2
#  PKG_LICENSE_FILES:=

# -PKG_SOURCE_URL:=https://github.com/openwrt/mt76
# +PKG_SOURCE_URL:=https://github.com/pktpls/mt76
#  PKG_SOURCE_PROTO:=git
# -PKG_SOURCE_DATE:=2024-09-29
# -PKG_SOURCE_VERSION:=680bc70f161fde0f167e2ae50c771be4775eb50a
# -PKG_MIRROR_HASH:=bcdb95e40cfceba56a565ad6b6d9f92a122e7230d0f7f950b3d39e4280723cca
# +PKG_SOURCE_DATE:=2024-10-05
# +PKG_SOURCE_VERSION:=2d428efca426202ae90d842070e66c6f5757df41
# +PKG_MIRROR_HASH:=f729066e8eefb3cd4fc6b283f51e3b051a9528a4219650141c9207d8f5acd167

#  PKG_MAINTAINER:=Felix Fietkau <nbd@nbd.name>
#  PKG_USE_NINJA:=0

# EOF

  cp feeds.conf.default feeds.conf
  cat >> feeds.conf << 'EOF'
src-git-full falter https://github.com/pktpls/falter-packages.git;dev
EOF
  ./scripts/feeds update -a
  ./scripts/feeds install -a

  echo > .config

  # https://github.com/cilium/pwru
  # https://retis.readthedocs.io

  cat >> target/linux/ramips/mt7621/config-6.6 << 'EOF'
CONFIG_FPROBE=y
EOF
  cat >> .config << 'EOF'
CONFIG_KERNEL_DEBUG_INFO=y
CONFIG_KERNEL_DEBUG_INFO_REDUCED=n
CONFIG_KERNEL_DEBUG_INFO_BTF=y
CONFIG_KERNEL_KPROBES=y
CONFIG_KERNEL_PERF_EVENTS=y
CONFIG_KERNEL_FTRACE=y
CONFIG_KERNEL_FUNCTION_TRACER=y
EOF

#   cat >> .config << 'EOF'
# CONFIG_TARGET_mediatek=y
# CONFIG_TARGET_mediatek_mt7622=y
# CONFIG_TARGET_mediatek_mt7622_DEVICE_linksys_e8450-ubi=y
# EOF
  cat >> .config << 'EOF'
CONFIG_TARGET_ramips=y
CONFIG_TARGET_ramips_mt7621=y
CONFIG_TARGET_ramips_mt7621_DEVICE_zyxel_nwa50ax=y
EOF

  cat >> .config << 'EOF'
CONFIG_IB=y
CONFIG_IB_STANDALONE=y
CONFIG_IMAGEOPT=y
CONFIG_PACKAGE_babeld=y
CONFIG_PACKAGE_bird2=y
CONFIG_PACKAGE_bird2c=y
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
CONFIG_PACKAGE_collectd-mod-rrdtool=y
CONFIG_PACKAGE_collectd-mod-snmp6=y
CONFIG_PACKAGE_collectd-mod-snmp=y
CONFIG_PACKAGE_collectd-mod-uptime=y
CONFIG_PACKAGE_collectd=y
CONFIG_PACKAGE_conntrackd=y
CONFIG_PACKAGE_coreutils-timeout=y
CONFIG_PACKAGE_coreutils=y
CONFIG_PACKAGE_ethtool=y
CONFIG_PACKAGE_falter-berlin-admin-keys=y
CONFIG_PACKAGE_falter-berlin-autoupdate-keys=y
CONFIG_PACKAGE_falter-berlin-autoupdate=y
CONFIG_PACKAGE_falter-berlin-bbbdigger=y
CONFIG_PACKAGE_falter-berlin-dhcp-defaults=y
CONFIG_PACKAGE_falter-berlin-firewall-defaults=y
CONFIG_PACKAGE_falter-berlin-freifunk-defaults=y
CONFIG_PACKAGE_falter-berlin-lib-guard=y
CONFIG_PACKAGE_falter-berlin-migration=y
CONFIG_PACKAGE_falter-berlin-network-defaults=y
CONFIG_PACKAGE_falter-berlin-olsrd-defaults=y
CONFIG_PACKAGE_falter-berlin-service-registrar=y
CONFIG_PACKAGE_falter-berlin-ssid-changer=y
CONFIG_PACKAGE_falter-berlin-statistics-defaults=y
CONFIG_PACKAGE_falter-berlin-system-defaults=y
CONFIG_PACKAGE_falter-berlin-tunneldigger=y
CONFIG_PACKAGE_falter-berlin-tunnelmanager=y
CONFIG_PACKAGE_falter-berlin-uhttpd-defaults=y
CONFIG_PACKAGE_falter-berlin-uplink-notunnel=y
CONFIG_PACKAGE_falter-berlin-uplink-tunnelberlin=y
CONFIG_PACKAGE_falter-common-olsr=y
CONFIG_PACKAGE_falter-common=y
CONFIG_PACKAGE_falter-policyrouting=y
CONFIG_PACKAGE_falter-profiles=y
CONFIG_PACKAGE_firewall=y
CONFIG_PACKAGE_gre=y
CONFIG_PACKAGE_ip-bridge=y
CONFIG_PACKAGE_ip-full=y
CONFIG_PACKAGE_ip-tiny=y
CONFIG_PACKAGE_ip=y
CONFIG_PACKAGE_iperf3=y
CONFIG_PACKAGE_iptables-mod-ipopt=y
CONFIG_PACKAGE_irqbalance=y
CONFIG_PACKAGE_iwinfo=y
CONFIG_PACKAGE_kmod-ipip=y
CONFIG_PACKAGE_kmod-ipt-ipopt=y
CONFIG_PACKAGE_kmod-l2tp-eth=y
CONFIG_PACKAGE_kmod-l2tp=y
CONFIG_PACKAGE_kmod-macvlan=y
CONFIG_PACKAGE_kmod-nft-bridge=y
CONFIG_PACKAGE_kmod-veth=y
CONFIG_PACKAGE_kmod-wireguard=y
CONFIG_PACKAGE_libatomic=y
CONFIG_PACKAGE_libiwinfo-lua=y
CONFIG_PACKAGE_libuci-lua=y
CONFIG_PACKAGE_lua=y
CONFIG_PACKAGE_luci-app-babeld=y
CONFIG_PACKAGE_luci-app-falter-autoupdate=y
CONFIG_PACKAGE_luci-app-falter-owm-ant=y
CONFIG_PACKAGE_luci-app-falter-owm-cmd=y
CONFIG_PACKAGE_luci-app-falter-owm-gui=y
CONFIG_PACKAGE_luci-app-falter-owm=y
CONFIG_PACKAGE_luci-app-falter-policyrouting=y
CONFIG_PACKAGE_luci-app-falter-service-registrar=y
CONFIG_PACKAGE_luci-app-ffwizard-falter=y
CONFIG_PACKAGE_luci-app-firewall=y
CONFIG_PACKAGE_luci-app-olsr-services=y
CONFIG_PACKAGE_luci-app-olsr=y
CONFIG_PACKAGE_luci-app-opkg=y
CONFIG_PACKAGE_luci-app-statistics=y
CONFIG_PACKAGE_luci-base=y
CONFIG_PACKAGE_luci-compat=y
CONFIG_PACKAGE_luci-lib-httpclient=y
CONFIG_PACKAGE_luci-lib-ip=y
CONFIG_PACKAGE_luci-lib-ipkg=y
CONFIG_PACKAGE_luci-lib-json=y
CONFIG_PACKAGE_luci-lib-jsonc=y
CONFIG_PACKAGE_luci-mod-admin-full=y
CONFIG_PACKAGE_luci-mod-falter=y
CONFIG_PACKAGE_luci-proto-ppp=y
CONFIG_PACKAGE_luci-ssl=y
CONFIG_PACKAGE_luci-theme-bootstrap=y
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_mosh-server=y
CONFIG_PACKAGE_mtr-nojson=y
CONFIG_PACKAGE_olsrd-mod-arprefresh=y
CONFIG_PACKAGE_olsrd-mod-dyn-gw=y
CONFIG_PACKAGE_olsrd-mod-jsoninfo=y
CONFIG_PACKAGE_olsrd-mod-nameservice=y
CONFIG_PACKAGE_olsrd-mod-txtinfo=y
CONFIG_PACKAGE_olsrd-mod-watchdog=y
CONFIG_PACKAGE_olsrd-utils=y
CONFIG_PACKAGE_olsrd=y
CONFIG_PACKAGE_pingcheck=y
CONFIG_PACKAGE_qos-scripts=y
CONFIG_PACKAGE_samplicator=y
CONFIG_PACKAGE_tcpdump-mini=y
CONFIG_PACKAGE_tmux=y
CONFIG_PACKAGE_uhttpd-mod-ubus=y
CONFIG_PACKAGE_uhttpd=y
CONFIG_PACKAGE_vnstat=y
CONFIG_PACKAGE_wg-installer-client=y
#CONFIG_PACKAGE_wg-installer-server-hotplug-babeld=y
#CONFIG_PACKAGE_wg-installer-server-hotplug-olsrd=y
#CONFIG_PACKAGE_wg-installer-server=y
CONFIG_PACKAGE_wireguard-tools=y
EOF

  make defconfig

  cat >> .config << 'EOF'
CONFIG_PACKAGE_luci-i18n-base-de=y
CONFIG_PACKAGE_luci-i18n-base-en=y
CONFIG_PACKAGE_luci-i18n-falter-autoupdate-de=y
CONFIG_PACKAGE_luci-i18n-falter-de=y
CONFIG_PACKAGE_luci-i18n-falter-en=y
CONFIG_PACKAGE_luci-i18n-falter-policyrouting-de=y
CONFIG_PACKAGE_luci-i18n-falter-policyrouting-en=y
CONFIG_PACKAGE_luci-i18n-falter-service-registrar-de=y
CONFIG_PACKAGE_luci-i18n-ffwizard-falter-de=y
CONFIG_PACKAGE_luci-i18n-ffwizard-falter-en=y
CONFIG_PACKAGE_luci-i18n-firewall-de=y
CONFIG_PACKAGE_luci-i18n-firewall-en=y
CONFIG_PACKAGE_luci-i18n-olsr-de=y
CONFIG_PACKAGE_luci-i18n-olsr-en=y
CONFIG_PACKAGE_luci-i18n-olsr2-de=y
CONFIG_PACKAGE_luci-i18n-olsr2-en=y
CONFIG_PACKAGE_luci-i18n-opkg-de=y
CONFIG_PACKAGE_luci-i18n-opkg-en=y
CONFIG_PACKAGE_luci-i18n-statistics-de=y
CONFIG_PACKAGE_luci-i18n-statistics-en=y
EOF

  make -j 20
  # make -j 1 V=s
  # make package/mt76/compile V=s
)

mkdir -p "$outdir"
cp -av "$builddir/bin/targets/$target/"*imagebuilder* "$outdir/"
cp -av "$builddir/bin/targets/$target/"*.buildinfo "$outdir/"
