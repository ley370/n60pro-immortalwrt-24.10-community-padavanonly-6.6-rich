# N60 Pro 丰富版 (rich) — ImmortalWrt 24.10-6.6

基于 padavanonly/immortalwrt-mt798x-6.6（分支 openwrt-24.10-6.6）的定制固件，面向磊科 N60 Pro（512MB 内存 / 128MB 闪存），有线主路由用途，无线默认关闭。

## 底版

- ImmortalWrt 24.10，内核 6.6 LTS，包管理 opkg
- MTK 闭源加速栈：HNAT + WARP + TurboACC-MTK（WARP_CHIPSET=mt7986）
- 闭源 mt_wifi 驱动（已装，默认关闭）

## 最新构建

- #4：100 个包，sysupgrade `.bin` 49,449,773 字节，SHA256 `64530021332a3283147b0006444daeccde54a50ecda70b6ca91e018ecb77b4af`，sha256sums 12/12，manifest 441 行
- 仓库当前脚本含两项修正（NAS 菜单并入服务、无线默认关双保险），尚未重编；下一轮构建以构建页产物为准

## 插件清单

| 功能 | 插件 |
|---|---|
| 代理 | PassWall2 + sing-box（只留 sing-box 内核）；HAProxy 负载均衡已开，自动切换在 LuCI 里配 |
| 去广告 | AdGuardHome（无 LuCI 界面，用其自带网页管理） |
| 备选去广告 / DNS | adblock、SmartDNS（已装，默认不启用；与 AdGuardHome 二选一，不同时跑） |
| 加速 | TurboACC-MTK + HNAT + WARP + BBR |
| 限速 | eqos-mtk；SQM + cake（已装，默认不启用；启用前须关 HNAT） |
| IPTV | igmpproxy + udpxy；mcproxy（备选，默认不启用） |
| USB / 磁盘 | block-mount、usb-storage(-uas)、usb3、ext4、f2fs、vfat、exfat、ntfs3（内核）、diskman、hd-idle、parted、e2fsprogs |
| 应用商店 | iStore（luci-app-store，istore 源） |
| 网络管理 | arpbind、opkg 界面、vnstat2、statistics、banip、DDNS、UPnP、WoL、WireGuard（luci-proto-wireguard + wireguard-tools） |
| 系统 | Argon 主题（默认，中文）、attendedsysupgrade、nlbwmon、ttyd、watchcat、accesscontrol、temp-status |

未包含：Samba / Transmission（NAS 已有）、QoSmate（与 HNAT 互斥）、OpenClash / Nikki / HomeProxy（代理核心只留 PassWall2）、文件浏览器（本版没有）。

## 默认设置

- LAN：192.168.6.1/24，DHCP 默认（客户端 192.168.6.100–249）
- 无线：默认关闭（两个射频均 disabled；开无线在 LuCI 里启用并设 SSID/密码）
- root：无密码，首次进 LuCI 后立即设置
- 时区：Asia/Shanghai（CST-8），NTP 为国内服务器
- LuCI：Argon 主题，简体中文

## 刷机

产物只有 sysupgrade `.bin`，走 U-Boot 网页恢复页直刷；没有 `.itb`。

刷机前备份节点（订阅链接/截图）与 LuCI 备份：旧 PassWall 配置不会自动迁移到 PassWall2，节点须重建；建议不保留设置。

## 刷后检查

1. 设管理员密码。
2. 确认无线两个射频均为禁用。
3. 服务菜单里应有“硬盘休眠”；不应再有顶级 NAS 菜单。
4. AdGuardHome 用其自带网页管理（本版无 LuCI 界面）；只启用一个 init 脚本。
5. PassWall2 自动切换在 LuCI 里配：负载均衡组（leastPing，设为默认节点）或给主节点挂备用节点开自动切换。
6. 测 HNAT 是否绕过 PassWall2 与 AdGuardHome（硬件加速可能使代理/DNS 旁路，须实机验证）。

## 注意事项

- 128MB 闪存：sing-box 约 30MB、AdGuardHome 约 40MB，/overlay 余量有限；空间紧张时插 USB 3.0 U 盘扩容 /overlay（USB 驱动已编进固件）。
- NTFS 靠内核 ntfs3；ntfs-3g 与之冲突，不得加回。
- adblock / SmartDNS / SQM / mcproxy 均为“装而不启用”，默认路径仍是 AdGuardHome + PassWall2 分流。
- iStore 商店里的插件不一定都有 24.10 版本，装不上时改用 LuCI → 系统 → 软件包或 `opkg install`。
- 每次重新运行都会拉取最新源码和软件包。

## 文件说明

- `.github/workflows/build.yml`：GitHub Actions 工作流（仅手动触发）
- `n60-pro.config`：编译配置（目标机型 + 软件包清单）
- `diy-part1.sh`：第三方源（passwall2、passwall_packages、istore）
- `diy-part2.sh`：编译后处理（Rust 编译修复；NAS 菜单并入服务；mtwifi 生成默认禁用无线）
- `files/etc/uci-defaults/99-n60pro-defaults`：首次启动设置（LAN 6.1、关无线、Argon、中文、时区）

## 构建记录

- #2：丰富版首次编成（99 包，`.bin` 48,620,333 字节）
- #3：失败（ntfs-3g 与 kmod-fs-ntfs3 冲突，package/install Error 255）
- #4：编成（100 包，含 iStore；ntfs-3g 已删）
