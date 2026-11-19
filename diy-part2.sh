#!/bin/bash
# diy-part2.sh - post-config tweaks (runs inside openwrt/ after .config is loaded)
# Wireless-off + Argon default theme + Chinese UI are set by
# files/etc/uci-defaults/99-n60pro-defaults on first boot.
#
# Rust host build fix (2026-11-15, build #2 failed on this):
# The host rustc (1.96.0) tries to download a prebuilt LLVM from Rust CI
# (`download-ci-llvm`), but that CI artifact URL returns 404, so the whole
# build fails with "ERROR: failed to download llvm from ci".
# Fix: force the Rust package to build LLVM from source instead.
# (Known upstream issue: https://github.com/immortalwrt/packages/issues/1854)
# Side effect: LLVM compiles from source, adding roughly 1 hour to the build.
sed -i 's/ci-llvm=true/ci-llvm=false/g' feeds/packages/lang/rust/Makefile
if grep -q 'ci-llvm=false' feeds/packages/lang/rust/Makefile; then
  echo "diy-part2: rust download-ci-llvm disabled"
else
  echo "diy-part2: WARNING: ci-llvm pattern not found in feeds/packages/lang/rust/Makefile"
fi

# NAS menu merged into Services: hd-idle and p910nd register their entries under
# admin/nas; moving them to admin/services makes the top-level NAS menu disappear.
# (2026-11-19: p910nd added by syncing with the standard edition, so it is moved too.)
# menu.d only exists after feeds are installed, so this belongs in diy-part2.sh.
sed -i 's|"admin/nas/hd_idle"|"admin/services/hd_idle"|' feeds/luci/applications/luci-app-hd-idle/root/usr/share/luci/menu.d/luci-app-hd-idle.json
sed -i 's|"admin/nas/p910nd"|"admin/services/p910nd"|' feeds/luci/applications/luci-app-p910nd/root/usr/share/luci/menu.d/luci-app-p910nd.json
if grep -q '"admin/services/hd_idle"' feeds/luci/applications/luci-app-hd-idle/root/usr/share/luci/menu.d/luci-app-hd-idle.json && grep -q '"admin/services/p910nd"' feeds/luci/applications/luci-app-p910nd/root/usr/share/luci/menu.d/luci-app-p910nd.json; then
  echo "diy-part2: NAS menu merged into Services (hd-idle, p910nd)"
else
  echo "diy-part2: WARNING: NAS menu move failed (menu.d pattern not found)"
fi

# Wireless disabled by default, second layer: the mtwifi detect function
# generates wifi-device sections named MT7986_1_1 / MT7986_1_2 (not radio0/radio1),
# so patch detect to generate them with disabled=1 from the start.
# (The first layer is 99-n60pro-defaults, which disables every wifi-device section.)
# mtwifi.sh lives in the source tree, not in a feed.
if grep -q 'set wireless.${dev}.serialize=1' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh; then
  sed -i 's|set wireless.${dev}.serialize=1|set wireless.${dev}.serialize=1\n\t\t\t\t\tset wireless.${dev}.disabled=1|' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
  if grep -q 'set wireless.${dev}.disabled=1' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh; then
    echo "diy-part2: mtwifi detect now generates disabled radios"
  else
    echo "diy-part2: WARNING: mtwifi disabled patch did not apply"
  fi
else
  echo "diy-part2: WARNING: mtwifi.sh anchor not found, wireless detect not patched"
fi
