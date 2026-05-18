#!/bin/bash
#=================================================
# Description: Newifi D2 minimal PassWall2 pre-feeds script
# License: MIT
#=================================================
set -euo pipefail

# Keep this target minimal. The generic DIY/diy-part1.sh clones extra third-party
# package collections; OpenWrt master plus PassWall feeds provide what this build needs.
rm -rf \
  package/small \
  package/openwrt-packages \
  package/luci-app-adguardhome
