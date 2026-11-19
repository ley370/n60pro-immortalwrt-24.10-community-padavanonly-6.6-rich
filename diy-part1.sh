#!/bin/bash
# diy-part1.sh - add third-party feeds (runs inside openwrt/ before feeds update)
#
# v12 (2026-11-15): PassWall2 feeds. PassWall2 is NOT in the official
# ImmortalWrt feeds, so both feeds below are required:
# - passwall2: luci-app-passwall2 itself
#   (new org: Openwrt-Passwall/openwrt-passwall2, was xiaorouji/openwrt-passwall2)
# - passwall_packages: its dependencies not in official feeds
#   (chinadns-ng, tcping, geoview, and the sing-box/xray helper packages)
#   https://github.com/xiaorouji/openwrt-passwall-packages.git;main
# 2026-11-16 钉版本做法已作废（B #2 失败根因，见下）：
# feeds.conf.default 里 ';' 后跟的东西会被 scripts/feeds 原样传给
# `git clone --branch`，而 --branch 只接受分支/标签名，不接受 40 位提交哈希；
# 钉提交哈希会报 "fatal: Remote branch <sha> not found in upstream origin"，
# Update feeds 失败。正确钉版本须在 feeds 更新完后再 git checkout 到指定提交，
# 本次先改回跟 main 浮动（A #1、原库 #5、B #1 都是这么过的），钉版本以后再议。
# The workflow then runs `./scripts/feeds update -a && ./scripts/feeds install -a`,
# so these feeds are picked up automatically. The grep guards make the
# script idempotent if it ever runs twice.
grep -q '^src-git passwall_packages ' feeds.conf.default || echo 'src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git;main' >> feeds.conf.default
grep -q '^src-git passwall2 ' feeds.conf.default || echo 'src-git passwall2 https://github.com/Openwrt-Passwall/openwrt-passwall2.git;main' >> feeds.conf.default
# iStore（2026-11-18 用户决定丰富版加）：luci-app-store + luci-lib-taskd。
# 源：linkease/istore main 分支（已核实：luci/luci-app-store 0.2.1-r1，
# 依赖 luci-lib-taskd 同在该源里；支持 ipk/opkg，24.10 用 ipk。
# 跟 main 浮动、不钉哈希，见 B #2 教训）。
grep -q '^src-git istore ' feeds.conf.default || echo 'src-git istore https://github.com/linkease/istore;main' >> feeds.conf.default
# AdGuardHome 的 LuCI 界面（2026-11-19 同步标准版）：rufengsuixing/luci-app-adguardhome v1.8。
# 24.10 的 feed 里没有 luci-app-adguardhome；作者文档的用法是编译时把仓库 clone 进软件包目录；
# 与 passwall feed 同样跟 master 浮动、不钉哈希。编译后以 .manifest 中 luci-app-adguardhome 在位为准。
[ -d package/luci-app-adguardhome ] || git clone --depth 1 https://github.com/rufengsuixing/luci-app-adguardhome.git package/luci-app-adguardhome
