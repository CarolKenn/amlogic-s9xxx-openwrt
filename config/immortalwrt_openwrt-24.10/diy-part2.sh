#!/bin/bash
#========================================================================================================================
# https://github.com/CarolKenn/amlogic-s9xxx-openwrt
# 斐讯 N1（S905D）专用：immortalwrt / openwrt-24.10
# Function: DIY script（更新 feeds 之后执行：改默认值、加插件、开 ccache）
# 参数：$1 = 默认 LAN IP，$2 = 是否启用 ccache
#========================================================================================================================
set -e

# ------------------------------- 基础配置 -------------------------------
default_ip="192.168.128.3"
ip_regex="^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
[[ -n "${1}" && "${1}" != "${default_ip}" && "${1}" =~ ${ip_regex} ]] && {
	echo "Modify default IP address to: ${1}"
	sed -i "/lan) ipad=\${ipaddr:-/s/\${ipaddr:-\"[^\"]*\"}/\${ipaddr:-\"${1}\"}/" package/base-files/*/bin/config_generate
}

# root 默认密码改为 password（首次登录后请立刻修改）
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' package/base-files/files/etc/shadow

# 写入源码信息，固件里能看到是哪条分支编的
sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%Y.%m.%d)'|g" package/base-files/files/etc/openwrt_release
sed -i "/DISTRIB_SOURCEREPO/d;/DISTRIB_SOURCECODE/d;/DISTRIB_SOURCEBRANCH/d" package/base-files/files/etc/openwrt_release
echo "DISTRIB_SOURCEREPO='github.com/immortalwrt/immortalwrt'" >>package/base-files/files/etc/openwrt_release
echo "DISTRIB_SOURCECODE='immortalwrt'" >>package/base-files/files/etc/openwrt_release
echo "DISTRIB_SOURCEBRANCH='openwrt-24.10'" >>package/base-files/files/etc/openwrt_release

# ccache
sed -i '/CONFIG_DEVEL/d' .config
sed -i '/CONFIG_CCACHE/d' .config
if [[ "${2}" == "true" ]]; then
	echo "CONFIG_DEVEL=y" >>.config
	echo "CONFIG_CCACHE=y" >>.config
	echo 'CONFIG_CCACHE_DIR="$(TOPDIR)/.ccache"' >>.config
else
	echo '# CONFIG_DEVEL is not set' >>.config
	echo "# CONFIG_CCACHE is not set" >>.config
	echo 'CONFIG_CCACHE_DIR=""' >>.config
fi

# ------------------------------- 附加插件 -------------------------------
# 晶晨宝盒：装/写 eMMC、在线升级都靠它
rm -rf package/luci-app-amlogic
git clone -q -b main https://github.com/ophub/luci-app-amlogic.git package/luci-app-amlogic

# 旁路由用途：sing-box 内核的 HomeProxy，2G 内存跑得动；DDNS 用于外网回连
cat >>.config <<'EOF'
CONFIG_PACKAGE_luci-app-amlogic=y
CONFIG_PACKAGE_luci-app-homeproxy=y
CONFIG_PACKAGE_luci-app-ddns-go=y
EOF

exit 0
