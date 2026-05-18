#!/bin/bash
# Complete local build script for Newifi D2 minimal ImmortalWrt + PassWall2 firmware.
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/immortalwrt/immortalwrt}"
REPO_BRANCH="${REPO_BRANCH:-openwrt-23.05}"
WORKDIR="${WORKDIR:-$PWD/workdir-newifi-d2}"
JOBS="${JOBS:-$(nproc)}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

sudo apt-get update
sudo apt-get install -y build-essential clang flex bison g++ gawk gcc-multilib g++-multilib \
  gettext git libncurses5-dev libssl-dev python3-distutils rsync unzip zlib1g-dev \
  file wget curl ccache libelf-dev subversion swig time xsltproc

mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d openwrt/.git ]; then
  git clone --depth 1 "$REPO_URL" -b "$REPO_BRANCH" openwrt
else
  git -C openwrt fetch --depth 1 origin "$REPO_BRANCH"
  git -C openwrt checkout "$REPO_BRANCH"
  git -C openwrt reset --hard "origin/$REPO_BRANCH"
fi

cd openwrt
cp "$ROOT_DIR/feeds.conf.default" feeds.conf.default
bash "$ROOT_DIR/DIY/diy-part1-d2-passwall2.sh"
./scripts/feeds update -a
rm -rf feeds/packages/lang/golang
svn export --force https://github.com/openwrt/packages/trunk/lang/golang feeds/packages/lang/golang
./scripts/feeds install -a
for pkg in geoview xray-core sing-box; do
  test -d "package/feeds/passwall_packages/$pkg" || { echo "Missing package/feeds/passwall_packages/$pkg" >&2; exit 1; }
done
test -d package/feeds/passwall2/luci-app-passwall2 || { echo "Missing luci-app-passwall2" >&2; exit 1; }
cp "$ROOT_DIR/newifi3.config" .config
bash "$ROOT_DIR/DIY/diy-part2-d2.sh"
make defconfig
make download -j"$JOBS"
find dl -size -1024c -print -delete
make -j"$JOBS" || make -j1 V=s

printf '\nFirmware output: %s\n' "$PWD/bin/targets/ramips/mt7621"
