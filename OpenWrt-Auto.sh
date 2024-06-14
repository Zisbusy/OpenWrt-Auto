#!/bin/bash
# 开始计时
startTime=$(date +%Y%m%d-%H:%M:%S)
startTime_s=$(date +%s)

# 执行
echo "自动化编译官方 OpenWrt"
echo "工作目录：/home"
cd /home

echo "设置本地网络代理：192.168.10.10:7890"
export http_proxy=http://192.168.10.10:7890
export https_proxy=http://192.168.10.10:7890

echo "安装一些编译要用的包..."
dnf -y install git perl wget rsync bzip2 patch tar ncurses-devel epel-release
# dnf -y install screen

echo "克隆 OpenWrt 源码..."
git clone https://github.com/openwrt/openwrt.git

echo "设置 OpenWrt 版本 v23.05.3"
cd /home/openwrt
git checkout v23.05.3

echo "更新 OpenWrt 源..."
./scripts/feeds update -a
echo "安装下载好的包: (可选)..."
./scripts/feeds install -a

echo "安装一些第三方包和一些设置..."
cd /home/openwrt/package

echo "安装主题 Argon..."
git clone https://github.com/jerrykuku/luci-theme-argon.git
echo "合并主题修改..."
rm -rf /home/openwrt/package/luci-theme-argon/luasrc/view/themes/argon/footer_login.htm
rm -rf /home/openwrt/package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
cp -rf /home/OpenWrt-Auto/file/argon/footer_login.htm /home/openwrt/package/luci-theme-argon/luasrc/view/themes/argon/
cp -rf /home/OpenWrt-Auto/file/argon/footer.htm /home/openwrt/package/luci-theme-argon/luasrc/view/themes/argon/

echo "安装应用 Luci-app-diskman..."
git clone https://github.com/lisaac/luci-app-diskman.git

echo "安装应用 DockerMan..."
git clone https://github.com/lisaac/luci-app-dockerman.git
echo "删除官方 DockerMan..."
rm -rf /home/openwrt/package/feeds/luci/luci-app-dockerman
echo "复制新的 DockerMan..."
cp -rf /home/openwrt/package/luci-app-dockerman/applications/luci-app-dockerman /home/openwrt/package/feeds/luci/luci-app-dockerman

echo "设置：WAN口绑定 eth0、LAN口绑定 eth1..."
rm -rf /home/openwrt/package/base-files/files/etc/board.d/99-default_network
cp -rf /home/OpenWrt-Auto/file/99-default_network /home/openwrt/package/base-files/files/etc/board.d/

echo "复制编译配置文件..."
cp -rf /home/OpenWrt-Auto/file/.config /home/openwrt/

# 执行脚本
echo "定位到 OpenWrt 工作目录：/home/openwrt"
cd /home/openwrt

echo "允许 Root 用户编译"
export FORCE_UNSAFE_CONFIGURE=1

echo "开始编译 - 4线程"
make -j4 V=s

# 计算时间并输出
endTime=$(date +%Y%m%d-%H:%M:%S)
endTime_s=$(date +%s)
sumTime=$((endTime_s - startTime_s))
hours=$((sumTime / 3600))
minutes=$((sumTime % 3600 / 60))
seconds=$((sumTime % 60))
echo "编译结束！"
echo "开始时间：$startTime"
echo "结束时间：$endTime"
if [ $hours -gt 0 ]; then
    echo "总共耗时：$hours 小时 $minutes 分钟 $seconds 秒"
elif [ $minutes -gt 0 ]; then
    echo "总共耗时：$minutes 分钟 $seconds 秒"
else
    echo "总共耗时：$seconds 秒"
fi

# 邮件通知设备
