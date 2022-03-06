#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default
#echo 'src-git vssr https://github.com/jerrykuku/luci-app-vssr' >>feeds.conf.default
#echo 'src-git bypass https://github.com/kiddin9/openwrt-bypass' >>feeds.conf.default
#sed -i '$a src-git small8 https://github.com/kenzok8/small-package' feeds.conf.default
#sed -i '$a src-git kiddin9 https://github.com/kiddin9/openwrt-packages' feeds.conf.default
#sed -i '$a src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
#sed -i '$a src-git small https://github.com/kenzok8/small' feeds.conf.default
#sed -i '$a src-git infinityfreedom https://github.com/xiaoqingfengATGH/luci-theme-infinityfreedom' feeds.conf.default
 
# Define My Package
git clone https://github.com/vernesong/OpenClash package/molun/luci-app-openclash
git clone https://github.com/jerrykuku/luci-app-jd-dailybonus package/molun/luci-app-jd-dailybonus
#git clone https://github.com/rufengsuixing/luci-app-adguardhome package/molun/luci-app-adguardhome
#git clone https://github.com/sirpdboy/luci-theme-opentopd package/molun/luci-theme-opentopd
#git clone https://github.com/zzsj0928/luci-app-pushbot package/molun/luci-app-pushbot
git clone -b 18.06 https://github.com/kiddin9/luci-theme-edge package/molun/luci-theme-edge
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon package/molun/luci-theme-argon
git clone https://github.com/jerrykuku/luci-app-argon-config package/molun/luci-app-argon-config
git clone https://github.com/thinktip/luci-theme-neobird package/molun/luci-theme-neobird
git clone https://github.com/xiaoqingfengATGH/luci-theme-infinityfreedom package/molun/luci-theme-infinityfreedom
