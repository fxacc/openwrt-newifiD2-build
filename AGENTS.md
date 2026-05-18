# Agent Instructions

This repository is an automated firmware build repository for Newifi D2.

## Primary Goal

Build firmware for the Newifi D2 router from the latest OpenWrt `master` branch with the latest maintained PassWall2 stack.

The build should prioritize a working, compact OpenWrt firmware image for Newifi D2 with PassWall2, Xray, Sing-box, and the geodata packages required by current routing modes.

## Required Target

- Device: Newifi D2
- OpenWrt source: `https://github.com/openwrt/openwrt`
- OpenWrt branch: `master`
- Main workflow: `.github/workflows/newifi3.yml`
- Main config: `newifi3.config`
- Feeds file: `feeds.conf.default`
- Local helper build script: `Scripts/build-newifi-d2-passwall2.sh`

Do not switch this build back to ImmortalWrt, Lean, Lienol, or older OpenWrt release branches unless explicitly requested.

## PassWall2 Requirements

Keep PassWall2 on the latest maintained upstream feeds:

- `https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main`
- `https://github.com/Openwrt-Passwall/openwrt-passwall2.git;main`

The firmware should support, or preserve the package/config path needed to support:

- VLESS Reality Vision through Xray
- VLESS Reality Vision through Sing-box where available
- Hysteria 2 support as much as the current OpenWrt master and PassWall2 package set allow

When package names or dependencies change upstream, update `feeds.conf.default`, `newifi3.config`, and the DIY scripts together so CI and local builds stay aligned.

## Build Policy

- Prefer OpenWrt `master` packages and feeds for compatibility with current PassWall2 dependencies.
- Keep the firmware minimal enough for Newifi D2 storage constraints.
- Avoid adding large unrelated LuCI apps, network services, or third-party package collections unless they are required for PassWall2, Xray, Sing-box, Hysteria 2, or geodata routing.
- Preserve default LAN IP `192.168.2.1` and hostname `Newifi-D2` unless explicitly asked to change them.
- Keep generated firmware artifacts under the existing GitHub Actions upload/release flow.

## Verification

For documentation-only edits, verify with:

```bash
git diff --check
```

For build-related edits, verify at minimum:

```bash
git diff --check
bash -n DIY/diy-part1-d2-passwall2.sh
bash -n DIY/diy-part2-d2.sh
bash -n Scripts/build-newifi-d2-passwall2.sh
```

If practical, trigger or run the automated build workflow. Full firmware compilation is expensive, so clearly state whether it was run.
