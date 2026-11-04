#!/bin/bash
# =============================================================================
# diy-plugins.sh —— 插件拉取（源自你 260329_diy.sh 同款清单，逻辑原样保留）
# 铁律沿用：GIT_TERMINAL_PROMPT=0 防卡死；每个 clone 用 || true 不中断
# 新增：拉取后打印“插件到位清单”写入 Summary，防止断链导致“编译成功但插件缺失”
# 注意：插件是否在固件里，仍由 .config 决定（menuconfig 勾选）；本脚本只负责把源码放进 package/diy
# =============================================================================
export GIT_TERMINAL_PROMPT=0
mkdir -p package/diy
echo "开始拉取定制插件到 package/diy ..."

# ==================== 主题与外观 ====================
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git       package/diy/luci-theme-argon       || true
git clone https://github.com/jerrykuku/luci-app-argon-config.git           package/diy/luci-app-argon-config  || true
git clone https://github.com/gngpp/luci-theme-design.git                   package/diy/luci-theme-design      || true
git clone https://github.com/gngpp/luci-app-design-config.git              package/diy/luci-app-design-config || true

# ==================== Sirpdboy 实用系列 ====================
git clone --depth=1 https://github.com/sirpdboy/luci-app-eqosplus.git      package/diy/luci-app-eqosplus      || true
git clone --depth=1 https://github.com/sirpdboy/luci-app-fastnet.git       package/diy/luci-app-fastnet       || true
git clone --depth=1 https://github.com/sirpdboy/luci-app-openlist2.git     package/diy/luci-app-openlist2     || true
git clone --depth=1 https://github.com/sirpdboy/luci-app-parentcontrol.git package/diy/luci-app-parentcontrol || true
git clone --depth=1 https://github.com/sirpdboy/luci-app-partexp.git       package/diy/luci-app-partexp       || true
git clone --depth=1 https://github.com/sirpdboy/luci-app-taskplan.git      package/diy/luci-app-taskplan      || true

# ==================== 其他高阶插件 ====================
git clone --depth=1 https://github.com/messense/aliyundrive-webdav.git     package/diy/luci-app-aliyundrive-webdav || true
git clone --depth=1 https://github.com/mchome/luci-app-iptvhelper.git      package/diy/luci-app-iptvhelper    || true
git clone --depth=1 https://github.com/ximiTech/luci-app-msd_lite.git      package/diy/luci-app-msd_lite      || true
git clone --depth=1 https://github.com/hudra0/qosmate.git                  package/diy/luci-app-qosmate       || true
git clone --depth=1 https://github.com/chenhw2/luci-app-turboacc.git       package/diy/luci-app-turboacc      || true
# wrtbwmon 弃用：主体仓库非标准 OpenWrt 包且 lean 树内无 wrtbwmon 符号（2026-11-03 编译失败根因）；流量监控改用 lean 自带 luci-app-nlbwmon
# git clone --depth=1 https://github.com/brvphoenix/luci-app-wrtbwmon.git    package/diy/luci-app-wrtbwmon      || true
git clone --depth=1 https://github.com/destan19/OpenAppFilter.git          package/diy/OpenAppFilter          || true
git clone --depth=1 https://github.com/sirpdboy/luci-app-ap-modem.git      package/diy/luci-app-ap-modem      || true
git clone --depth=1 https://github.com/sirpdboy/luci-app-clouddrive2.git   package/diy/luci-app-clouddrive2   || true

# ==================== 全局去重（防与 feeds/package/lean 撞名冲突）====================
echo "执行包冲突全局去重 ..."
for x in $(ls package/diy); do
    find feeds/ -maxdepth 4 -type d -name "$x" -exec rm -rf {} \; 2>/dev/null
    find package/ -maxdepth 4 -type d -name "$x" -not -path "package/diy/*" -exec rm -rf {} \; 2>/dev/null
done

# ==================== 删除易冲突组件 ====================
rm -rf feeds/*/luci-app-mmdvm package/*/luci-app-mmdvm
rm -rf feeds/*/luci-theme-mmdvm package/*/luci-theme-mmdvm

# ==================== 插件到位核对表（写进本次运行 Summary）=====================
echo "### 插件到位核对表" >> "$GITHUB_STEP_SUMMARY" 2>/dev/null || true
{
  echo "| 插件 | 是否就位 |"; echo "|---|---|"
  miss=0
  for x in $(ls package/diy 2>/dev/null); do
    if [ -n "$(find package/diy/$x -name Makefile -o -name '*.mk' 2>/dev/null | head -1)" ]; then
      echo "| $x | ✅ |"
    else
      echo "| $x | ❌ 缺 Makefile(可能断链) |"; miss=$((miss+1))
    fi
  done
  echo ""
  echo "疑似断链数: $miss（0 不代表 .config 已勾选它们，只代表源码已放入）"
} >> "$GITHUB_STEP_SUMMARY" 2>/dev/null || true

echo "diy-plugins 完成。"
