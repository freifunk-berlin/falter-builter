#!/usr/bin/env bash

set -e
set -o pipefail

function usage() {
  echo "usage: imagebuilder/vm-mmio/imagebuilder.sh <target>"
  echo
  echo "target names:"
  echo "    armvirt/64  x86/64"
  echo
  exit 1
}

[ -n "$1" ] && target="$1" || usage >&2

set -x

outdir="out/imagebuilder/vm-mmio/$target/"
builddir="tmp/imagebuilder/vm-mmio"
rm -rf "$builddir"
rm -rf "$builddir/bin"
mkdir -p "$builddir"

(
  git clone https://git.openwrt.org/openwrt/openwrt.git "$builddir"
  # git clone https://github.com/openwrt/openwrt.git "$builddir"
  # git clone /home/user/w/ow/openwrt "$builddir"
  cd "$builddir"

  git checkout f8282da11ee77c36acb1bd94c99b76ce13257ab9 # openwrt 21.02.7

  cp feeds.conf.default feeds.conf
  cat >> feeds.conf << 'EOF'
src-git falter https://github.com/freifunk-berlin/falter-packages.git;openwrt-21.02
EOF
  ./scripts/feeds update -a
  ./scripts/feeds install -a

  echo > .config

  if [ ".x86/64" = ".$target" ] ; then
    cat >> target/linux/x86/64/config-5.4 << 'EOF'
CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES=y
EOF
    cat >> .config << 'EOF'
CONFIG_TARGET_x86=y
CONFIG_TARGET_x86_64=y
CONFIG_TARGET_x86_64_DEVICE_generic=y
EOF

  elif [ ".armvirt/64" = ".$target" ] ; then
    cat >> target/linux/armvirt/config-5.4 << 'EOF'
CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES=y
EOF
    cat >> .config << 'EOF'
CONFIG_TARGET_armvirt=y
CONFIG_TARGET_armvirt_64=y
CONFIG_TARGET_armvirt_64_DEVICE_default=y
EOF

  else
    echo "unsupported target: $target" && exit 1
  fi

  cat >> .config << 'EOF'
CONFIG_IB=y
CONFIG_IB_STANDALONE=y
CONFIG_IMAGEOPT=y
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
CONFIG_PACKAGE_collectd-mod-uptime=y
CONFIG_PACKAGE_collectd=y
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
CONFIG_PACKAGE_ip-full=y
CONFIG_PACKAGE_ip-tiny=y
CONFIG_PACKAGE_ip=y
CONFIG_PACKAGE_iperf3=y
CONFIG_PACKAGE_iwinfo=y
CONFIG_PACKAGE_kmod-ipip=y
CONFIG_PACKAGE_kmod-l2tp-eth=y
CONFIG_PACKAGE_kmod-l2tp=y
CONFIG_PACKAGE_kmod-macvlan=y
CONFIG_PACKAGE_kmod-nft-bridge=y
CONFIG_PACKAGE_kmod-veth=y
CONFIG_PACKAGE_libatomic=y
CONFIG_PACKAGE_libiwinfo-lua=y
CONFIG_PACKAGE_libuci-lua=y
CONFIG_PACKAGE_lua=y
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
CONFIG_PACKAGE_luci-app-olsr2=y
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
CONFIG_PACKAGE_mtr=y
CONFIG_PACKAGE_olsrd-mod-arprefresh=y
CONFIG_PACKAGE_olsrd-mod-dyn-gw=y
CONFIG_PACKAGE_olsrd-mod-jsoninfo=y
CONFIG_PACKAGE_olsrd-mod-nameservice=y
CONFIG_PACKAGE_olsrd-mod-txtinfo=y
CONFIG_PACKAGE_olsrd-utils=y
CONFIG_PACKAGE_olsrd=y
CONFIG_PACKAGE_oonf-olsrd2=y
CONFIG_PACKAGE_pingcheck=y
CONFIG_PACKAGE_qos-scripts=y
CONFIG_PACKAGE_tcpdump-mini=y
CONFIG_PACKAGE_tmux=y
CONFIG_PACKAGE_uhttpd-mod-ubus=y
CONFIG_PACKAGE_uhttpd=y
CONFIG_PACKAGE_vnstat=y
CONFIG_PACKAGE_wg-installer-client=y
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
)

mkdir -p "$outdir"
cp -av "$builddir/bin/targets/$target/"*imagebuilder* "$outdir/"
cp -av "$builddir/bin/targets/$target/"*.buildinfo "$outdir/"
