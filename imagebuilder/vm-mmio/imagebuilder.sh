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

  git checkout .
  git checkout 57a6d97ddf8f6541a52e0f8fad8c6f47685a1bc3 # openwrt 21.02.7

  git apply --ignore-whitespace << 'EOF'
diff --git a/package/boot/grub2/Makefile b/package/boot/grub2/Makefile
index 46e3597cc2..98f6482b07 100644
--- a/package/boot/grub2/Makefile
+++ b/package/boot/grub2/Makefile
@@ -84,6 +84,8 @@ HOST_MAKE_FLAGS += \
        TARGET_RANLIB=$(TARGET_RANLIB) \
        LIBLZMA=$(STAGING_DIR_HOST)/lib/liblzma.a

+HOST_CFLAGS += -std=gnu17
+
 TARGET_CFLAGS := $(filter-out -fno-plt,$(TARGET_CFLAGS))

 define Host/Configure
diff --git a/package/utils/jsonfilter/Makefile b/package/utils/jsonfilter/Makefile
index 6b7557b38c..bd9d5bdd8b 100644
--- a/package/utils/jsonfilter/Makefile
+++ b/package/utils/jsonfilter/Makefile
@@ -5,9 +5,9 @@ PKG_RELEASE:=1

 PKG_SOURCE_PROTO:=git
 PKG_SOURCE_URL=$(PROJECT_GIT)/project/jsonpath.git
-PKG_SOURCE_DATE:=2018-02-04
-PKG_SOURCE_VERSION:=c7e938d6582a436dddc938539e72dd1320625c54
-PKG_MIRROR_HASH:=0601b4d7aa5ee096e99388a57cb0701673ab58fccd6ed2984a2abbd4f846e045
+PKG_SOURCE_DATE:=2025-04-18
+PKG_SOURCE_VERSION:=8a86fb78235b5d7925b762b7b0934517890cc034
+PKG_MIRROR_HASH:=06b763387d00faae0e62af68626588ff2b8f12e0e6821950ae5422033df32757
 CMAKE_INSTALL:=1

 PKG_MAINTAINER:=Jo-Philipp Wich <jo@mein.io>
diff --git a/toolchain/gdb/Makefile b/toolchain/gdb/Makefile
index 05e3c7de3c..23f6b81edc 100644
--- a/toolchain/gdb/Makefile
+++ b/toolchain/gdb/Makefile
@@ -19,6 +19,8 @@ HOST_BUILD_DIR:=$(BUILD_DIR_TOOLCHAIN)/$(GDB_DIR)

 HOST_BUILD_PARALLEL:=1

+HOST_CFLAGS += -std=gnu17
+
 include $(INCLUDE_DIR)/toolchain-build.mk

 HOST_CONFIGURE_VARS += \
@@ -26,6 +28,7 @@ HOST_CONFIGURE_VARS += \
        gdb_cv_func_sigsetjmp=yes

 HOST_CONFIGURE_ARGS = \
+  CFLAGS="$(HOST_CFLAGS)" \
        --prefix=$(TOOLCHAIN_DIR) \
        --build=$(GNU_HOST_NAME) \
        --host=$(GNU_HOST_NAME) \
@@ -44,6 +47,8 @@ HOST_CONFIGURE_ARGS = \
        --disable-gas \
        --disable-sim

+HOST_CFLAGS += -std=gnu17
+
 define Host/Install
        mkdir -p $(TOOLCHAIN_DIR)/bin
        $(INSTALL_BIN) $(HOST_BUILD_DIR)/gdb/gdb $(TOOLCHAIN_DIR)/bin/$(TARGET_CROSS)gdb
diff --git a/tools/bison/Makefile b/tools/bison/Makefile
index 8f3043fcb8..41760de527 100644
--- a/tools/bison/Makefile
+++ b/tools/bison/Makefile
@@ -17,6 +17,7 @@ HOST_BUILD_PARALLEL:=1

 include $(INCLUDE_DIR)/host-build.mk

+HOST_CFLAGS += -std=gnu17
 HOST_CONFIGURE_ARGS += --enable-threads=posix --disable-nls

 define Host/Clean
diff --git a/tools/e2fsprogs/Makefile b/tools/e2fsprogs/Makefile
index d7c994c338..178f3ffadc 100644
--- a/tools/e2fsprogs/Makefile
+++ b/tools/e2fsprogs/Makefile
@@ -23,7 +23,7 @@ include $(INCLUDE_DIR)/host-build.mk
 ifneq ($(shell $(HOSTCC) --version | grep clang),)
   HOST_CFLAGS += -D__GNUC_PREREQ\(...\)=0 -Dloff_t=off_t
 endif
-HOST_CFLAGS += $(FPIC)
+HOST_CFLAGS += $(FPIC) -std=gnu17

 HOST_CONFIGURE_ARGS += \
        --disable-elf-shlibs \
diff --git a/tools/gmp/Makefile b/tools/gmp/Makefile
index 967cf6817b..d04f243f15 100644
--- a/tools/gmp/Makefile
+++ b/tools/gmp/Makefile
@@ -21,6 +21,8 @@ include $(INCLUDE_DIR)/host-build.mk

 unexport CFLAGS

+HOST_CFLAGS += -std=gnu17
+
 HOST_CONFIGURE_ARGS += \
        --enable-static \
        --disable-shared \
diff --git a/tools/m4/Makefile b/tools/m4/Makefile
index 0a358c35f1..949b3fd6a6 100644
--- a/tools/m4/Makefile
+++ b/tools/m4/Makefile
@@ -19,6 +19,7 @@ HOST_BUILD_PARALLEL:=1

 include $(INCLUDE_DIR)/host-build.mk

+HOST_CFLAGS += -std=gnu17
 HOST_CONFIGURE_VARS += gl_cv_func_strstr_linear=no

 define Host/Clean
diff --git a/tools/squashfskit4/Makefile b/tools/squashfskit4/Makefile
index 9ed10ecef9..cd0dd58e5b 100644
--- a/tools/squashfskit4/Makefile
+++ b/tools/squashfskit4/Makefile
@@ -17,6 +17,8 @@ HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/squashfskit-v$(PKG_VERSION)

 include $(INCLUDE_DIR)/host-build.mk

+HOST_CFLAGS += -std=gnu17
+
 define Host/Compile
        +$(HOST_MAKE_VARS) \
        $(MAKE) -C $(HOST_BUILD_DIR)/squashfs-tools \

EOF
  git diff --stat

  cp feeds.conf.default feeds.conf
  cat >> feeds.conf << 'EOF'
src-git falter https://github.com/freifunk-berlin/falter-packages.git;openwrt-21.02
EOF
  ./scripts/feeds update -a
  ./scripts/feeds install -a

  sed -i 's#cc -o contrib/lemon#cc -std=gnu17 -o contrib/lemon#g' feeds/luci/modules/luci-base/src/Makefile

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
  # make toolchain/compile -j 1 V=s
)

mkdir -p "$outdir"
cp -av "$builddir/bin/targets/$target/"*imagebuilder* "$outdir/"
cp -av "$builddir/bin/targets/$target/"*.buildinfo "$outdir/"
