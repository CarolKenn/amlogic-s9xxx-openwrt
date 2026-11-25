#!/bin/bash
#========================================================================================================================
# https://github.com/CarolKenn/amlogic-s9xxx-openwrt
# 斐讯 N1（S905D）专用：immortalwrt / openwrt-24.10
# Function: DIY script（更新 feeds 之前执行：删包、换源、改默认值）
#========================================================================================================================

# 删掉用不上的东西：autosamba 会和预置的固定共享（movie → /mnt/movie）抢配置，
# ipv6-helper 在旁路由场景下容易把 IPv6 拉起来，先去掉。
rm -rf package/emortal/autosamba package/emortal/ipv6-helper

# N1 只有单网口 + 单频 Wi-Fi，且默认禁用无线，这些包纯占空间
rm -rf feeds/luci/applications/luci-app-wifischedule 2>/dev/null || true

# 第三方源（按需打开）
# sed -i '$a src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
