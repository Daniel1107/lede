#!/bin/sh
# =============================================================================
# 99-custom.sh —— 首启注入（源自你 99-custom-init.txt，占位符由 workflow sed 替换）
# 占位符：__LAN_IP__（面板 lan_ip）  __THEME__（面板 theme）  __ROOT_PASS__（secrets.ROOT_PASSWD）
# 部署到固件 files/etc/uci-defaults/99-custom.sh，开机执行一次后自动删除（uci-defaults 机制）
# =============================================================================

# 1. LAN 管理 IP
uci set network.lan.ipaddr='__LAN_IP__'

# 2. 网口分配：eth0=WAN，其余桥接为 LAN
uci set network.wan.ifname='eth0'
uci set network.lan.type='bridge'
uci set network.lan.ifname='eth1 eth2 eth3'

# 3. root 密码（唯一正确姿势：chpasswd）
echo "root:__ROOT_PASS__" | chpasswd

# 4. 默认主题（存在才设，避免主题缺失导致后台白屏）
if [ -d "/www/luci-static/__THEME__" ]; then
    uci set luci.main.mediaurlbase='/luci-static/__THEME__'
fi

# 5. 提交并自我销毁
uci commit
exit 0

# kiddin9 (openwrt.ai) 第二软件源：官方源缺的插件这里搜
if ! grep -q "dl.openwrt.ai" /etc/opkg/customfeeds.conf 2>/dev/null; then
  echo "src/gz kiddin9 https://dl.openwrt.ai/latest/packages/x86_64/kiddin9/" >> /etc/opkg/customfeeds.conf
  opkg update >/dev/null 2>&1 || true
fi
