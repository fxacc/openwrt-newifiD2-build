#!/bin/bash
#=================================================
# Description: Newifi D2 minimal PassWall2 firmware customizations
# License: MIT
#=================================================
set -euo pipefail

BUILD_DATE="$(TZ=Asia/Shanghai date '+%Y.%m.%d')"
BUILD_TIME="$(TZ=Asia/Shanghai date '+%Y-%m-%d %H:%M:%S %Z')"

# Default LAN IP: 192.168.2.1
sed -i 's/192\.168\.1\.1/192.168.2.1/g' package/base-files/files/bin/config_generate

# Hostname: Newifi-D2
sed -i 's/OpenWrt/Newifi-D2/g' package/base-files/files/bin/config_generate
sed -i 's/ImmortalWrt/Newifi-D2/g' package/base-files/files/bin/config_generate

# Version string contains the compile date.
sed -i '/^DISTRIB_DESCRIPTION=/d' package/base-files/files/etc/openwrt_release
cat >> package/base-files/files/etc/openwrt_release <<EOF_RELEASE
DISTRIB_DESCRIPTION='Newifi-D2 minimal PassWall2 build ${BUILD_DATE} @ %D %V'
DISTRIB_BUILD_DATE='${BUILD_TIME}'
EOF_RELEASE

# DNS cache tuning for long-running routers; avoid appending duplicate lines on reruns.
DNSMASQ_CONF="package/network/services/dnsmasq/files/dnsmasq.conf"
sed -i '/^# Newifi D2 DNS cache tuning$/,/^min-cache-ttl=3600$/d' "$DNSMASQ_CONF"
cat >> "$DNSMASQ_CONF" <<'EOF_DNS'
# Newifi D2 DNS cache tuning
#max-ttl=600
neg-ttl=600
min-cache-ttl=3600
EOF_DNS


# PassWall main branch currently carries newer Go cores (for example Xray 26.x)
# that can require a newer Go toolchain than ImmortalWrt 23.05 provides. The
# workflow/local build script removes them before feeds install; this is a second
# guard to remove any remaining source directories or installed symlinks.
rm -rf \
  feeds/passwall_packages/xray-core \
  feeds/passwall_packages/sing-box \
  package/feeds/passwall_packages/xray-core \
  package/feeds/passwall_packages/sing-box
if [ -e feeds/passwall_packages/xray-core ] || [ -e package/feeds/passwall_packages/xray-core ]; then
  echo "ERROR: PassWall main-branch xray-core is still present; refusing to build with incompatible Go requirements." >&2
  exit 1
fi

# Remove unwanted package directories if any feed brings them in, ensuring the image stays minimal.
rm -rf \
  feeds/packages/net/adguardhome \
  feeds/packages/net/zerotier \
  feeds/luci/applications/luci-app-adguardhome \
  feeds/luci/applications/luci-app-zerotier \
  package/feeds/luci/luci-app-openclash \
  package/feeds/luci/luci-app-ssr-plus \
  package/feeds/packages/adguardhome \
  package/feeds/packages/zerotier
