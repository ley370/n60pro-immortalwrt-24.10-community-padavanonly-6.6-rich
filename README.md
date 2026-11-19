# N60 Pro 丰富版 (rich) — ImmortalWrt 24.10-6.6

基于 padavanonly/immortalwrt-mt798x-6.6（分支 openwrt-24.10-6.6）的定制固件，面向磊科 N60 Pro（512MB 内存 / 128MB 闪存），有线主路由用途，无线默认关闭。

## 一、固件配置

### 底版

- ImmortalWrt 24.10，内核 6.6 LTS，包管理 opkg
- MTK 闭源加速栈：HNAT + WARP + TurboACC-MTK（WARP_CHIPSET=mt7986）
- 闭源 mt_wifi 驱动（已装，默认关闭）

### 默认设置

- LAN：192.168.6.1/24，DHCP 默认（客户端 192.168.6.100–249）
- 无线：默认关闭（两个射频均 disabled；开无线在 LuCI 里启用并设 SSID/密码）
- root：无密码，首次进 LuCI 后立即设置
- 时区：Asia/Shanghai（CST-8），NTP 为国内服务器
- LuCI：Argon 主题，简体中文

### 文件说明

- `.github/workflows/build.yml`：GitHub Actions 工作流（仅手动触发）
- `n60-pro.config`：编译配置（目标机型 + 软件包清单，106 个包）
- `diy-part1.sh`：第三方源（passwall2、passwall_packages、istore）
- `diy-part2.sh`：编译后处理（Rust 编译修复；NAS 菜单并入服务；mtwifi 生成默认禁用无线）
- `files/etc/uci-defaults/99-n60pro-defaults`：首次启动设置（LAN 6.1、关无线、Argon、中文、时区）

## 二、功能效果

| 功能 | 插件与效果 |
|---|---|
| 代理 | PassWall2 + sing-box（只留 sing-box 内核）；HAProxy 负载均衡已开，自动切换在 LuCI 里配 |
| 去广告 | AdGuardHome + LuCI 界面（diy-part1 clone，v1.8） |
| 备选去广告 / DNS | adblock、SmartDNS（已装，默认不启用；与 AdGuardHome 二选一，不同时跑） |
| 加速 | TurboACC-MTK + HNAT + WARP + BBR |
| 限速 | eqos-mtk；SQM + cake（已装，默认不启用；启用前须关 HNAT） |
| IPTV | igmpproxy + udpxy；mcproxy（备选，默认不启用） |
| USB / 磁盘 | block-mount、usb-storage(-uas)、usb3、ext4、f2fs、vfat、exfat、ntfs3（内核）、diskman、hd-idle、parted、e2fsprogs |
| 打印服务器 | p910nd + LuCI（USB 打印机插上即全网共享，9100 端口） |
| 应用商店 | iStore（luci-app-store，istore 源） |
| 网络管理 | arpbind、opkg 界面、vnstat2、statistics、banip、DDNS、UPnP、WoL、WireGuard（luci-proto-wireguard + wireguard-tools） |
| 定时重启 | autoreboot（LuCI 里设重启计划，默认不启用） |
| 自定义命令 | commands（LuCI 里存常用 shell 命令） |
| 系统 | Argon 主题（默认，中文）、attendedsysupgrade、nlbwmon、ttyd、watchcat、accesscontrol、temp-status |

效果说明：

- AdGuardHome 有 LuCI 界面；该 LuCI 包自带 /etc/init.d/AdGuardHome（大写），与本体 init 并存，刷后核查只启用一个。
- adblock / SmartDNS / SQM / mcproxy 均为“装而不启用”，默认路径仍是 AdGuardHome + PassWall2 分流。
- HNAT 硬件加速可能绕过 PassWall2 与 AdGuardHome，须实机验证。

## 三、使用方法

### 刷机

产物只有 sysupgrade `.bin`，走 U-Boot 网页恢复页直刷；没有 `.itb`。

刷机前备份节点（订阅链接/截图）与 LuCI 备份：旧 PassWall 配置不会自动迁移到 PassWall2，节点须重建；建议不保留设置。

### 刷后检查

1. 设管理员密码。
2. 确认无线两个射频均为禁用。
3. 服务菜单里应有“硬盘休眠”与“p910nd - 打印服务器”；不应再有顶级 NAS 菜单。
4. AdGuardHome 的 LuCI 界面在位；只启用一个 init 脚本。
5. PassWall2 自动切换在 LuCI 里配：负载均衡组（leastPing，设为默认节点）或给主节点挂备用节点开自动切换。
6. 测 HNAT 是否绕过 PassWall2 与 AdGuardHome。

### 注意事项

- 128MB 闪存：sing-box 约 30MB、AdGuardHome 约 40MB，/overlay 余量有限；空间紧张时插 USB 3.0 U 盘扩容 /overlay（USB 驱动已编进固件）。
- NTFS 靠内核 ntfs3；ntfs-3g 与之冲突，不得加回。
- iStore 商店里的插件不一定都有 24.10 版本，装不上时改用 LuCI → 系统 → 软件包或 `opkg install`。
- 每次重新运行都会拉取最新源码和软件包。

## 四、配置调整变更历史

### 修订记录

| 时间 | 版本 | 变更内容 |
|---|---|---|
| 2026-11-18 | 构建 #2 | 丰富版首次编成（99 包，`.bin` 48,620,333 字节） |
| 2026-11-18 | 构建 #3 | 构建失败（ntfs-3g 与 kmod-fs-ntfs3 冲突，package/install Error 255） |
| 2026-11-18 17:38 | 构建 #4 | 编成（99 包，含 iStore；ntfs-3g 已删） |
| 2026-11-18 22:53 | 构建 #4 | README 同步最新状态（简洁版废弃、LAN 6.1、.bin 刷机） |
| 2026-11-18 23:51 | 构建 #4（未重编） | NAS 菜单并入服务、无线默认关双保险应用到脚本；README 改写为纯固件说明 |
| 2026-11-18 23:55 | 构建 #4（未重编） | README 按四类范围重组（固件配置 / 功能效果 / 使用方法 / 配置调整变更历史） |
| 2026-11-18 23:56 | 构建 #4（未重编） | README 增加修订记录（本条） |
| 2026-11-19 00:00 | 构建 #4（未重编） | 修正包数：100→99（#4 删 ntfs-3g 后实为 99 行，此前误记 100） |
| 2026-11-19 02:10 | 构建 #5 | 编成（99 包，含 iStore；#6 两项修法已编入；`.bin` 49,449,773 字节，SHA256 `85b5da90…`） |
| 2026-11-19 08:05 | 构建 #5（未重编） | 同步标准版：加打印机（p910nd + LuCI + kmod-usb-printer）、定时重启、自定义命令、AdGuardHome LuCI（diy-part1 clone）；包数 99→106 |
| 2026-11-19 08:09 | 构建 #5（未重编） | README 口径调整：删“未包含”与“当前构建”两节，历史记录只留修订记录；README 只说明当前版本 |
| 2026-11-19 10:13 | 构建 #6 | 编成（106 包，含打印机、定时重启、自定义命令、AdGuardHome LuCI；.bin 49,552,173 字节，SHA256 `13c8a370…`） |
