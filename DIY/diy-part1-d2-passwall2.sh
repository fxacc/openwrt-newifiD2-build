#!/bin/bash
#=================================================
# Description: Newifi D2 minimal PassWall2 pre-feeds script
# License: MIT
#=================================================
set -euo pipefail

# Keep this target minimal. The generic DIY/diy-part1.sh clones the whole
# kenzok8/small collection; PassWall2 and its geodata helpers are supplied by
# feeds.conf.default instead, so the full third-party bundle is unnecessary.
rm -rf \
  package/small \
  package/openwrt-packages \
  package/luci-app-adguardhome
