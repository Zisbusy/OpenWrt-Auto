#!/bin/bash

if [ ! -n "$1" ] ;then
echo "编译机型参数未添加！"
exit 0
fi

if [ "$1" != "x86" ]&&[ "$1" != "erx" ] ;then
echo "编译机型参数错误！"
exit 0
fi

# 开始计时
startTime=$(date +%Y%m%d-%H:%M:%S)
startTime_s=$(date +%s)

# 执行
echo "自动化编译 OpenWrt v23.05.3" | tee -a /home/openwrt-auto/log.txt
echo "工作目录：/home" | tee -a /home/openwrt-auto/log.txt

if [ "$1" == "x86" ] ;then
echo "目标机型：x86" | tee -a /home/openwrt-auto/log.txt
fi

if [ "$1" == "erx" ] ;then
echo "目标机型：Ubiquiti EdgeRouter X" | tee -a /home/openwrt-auto/log.txt
fi

echo "安装一些编译要用的包..." | tee -a /home/openwrt-auto/log.txt
dnf -y install perl wget rsync bzip2 patch tar ncurses-devel

echo "克隆 OpenWrt 源码..." | tee -a /home/openwrt-auto/log.txt
cd /home
git clone https://github.com/openwrt/openwrt.git

echo "设置 OpenWrt 版本 v23.05.3" | tee -a /home/openwrt-auto/log.txt
cd /home/openwrt
git checkout v23.05.3

echo "更新 OpenWrt 源..." | tee -a /home/openwrt-auto/log.txt
./scripts/feeds update -a
echo "安装下载好的包..." | tee -a /home/openwrt-auto/log.txt
./scripts/feeds install -a

echo "安装一些第三方包和一些设置..." | tee -a /home/openwrt-auto/log.txt

echo "安装主题 Argon..." | tee -a /home/openwrt-auto/log.txt
cp -rf /home/openwrt-auto/23.05.3/package/luci-theme-argon/ /home/openwrt/package/

echo "删除访问主页跳转提示文案..." | tee -a /home/openwrt-auto/log.txt
cp -rf /home/openwrt-auto/23.05.3/package/luci/index.html /home/openwrt/feeds/luci/modules/luci-base/root/www/

echo "设置：时区 Asia/Shanghai、NTP 服务器、默认网关..." | tee -a /home/openwrt-auto/log.txt
rm -rf /home/openwrt/package/base-files/files/bin/config_generate
cp -rf /home/openwrt-auto/23.05.3/config/config_generate /home/openwrt/package/base-files/files/bin/
chmod 755 /home/openwrt/package/base-files/files/bin/config_generate

if [ "$1" == "x86" ] ;then
echo "设置：WAN口绑定 eth0、LAN口绑定 eth1..." | tee -a /home/openwrt-auto/log.txt
rm -rf /home/openwrt/package/base-files/files/etc/board.d/99-default_network
cp -rf /home/openwrt-auto/23.05.3/config/99-default_network /home/openwrt/package/base-files/files/etc/board.d/
fi

echo "复制编译配置文件..." | tee -a /home/openwrt-auto/log.txt
if [ "$1" == "x86" ] ;then
cp -rf /home/openwrt-auto/23.05.3/config/x86/.config /home/openwrt/
fi
if [ "$1" == "erx" ] ;then
cp -rf /home/openwrt-auto/23.05.3/config/erx/.config /home/openwrt/
fi

# 执行脚本
echo "定位到 OpenWrt 工作目录：/home/openwrt" | tee -a /home/openwrt-auto/log.txt
cd /home/openwrt

echo "允许 Root 用户编译" | tee -a /home/openwrt-auto/log.txt
export FORCE_UNSAFE_CONFIGURE=1

echo "获取 CPU 核心数" | tee -a /home/openwrt-auto/log.txt
num=`cat /proc/cpuinfo |grep processor  | wc -l` 
echo "开始编译 - "$num"线程" | tee -a /home/openwrt-auto/log.txt
make -j$num V=s

# 计算时间并输出
endTime=$(date +%Y%m%d-%H:%M:%S)
endTime_s=$(date +%s)
sumTime=$((endTime_s - startTime_s))
hours=$((sumTime / 3600))
minutes=$((sumTime % 3600 / 60))
seconds=$((sumTime % 60))
echo "编译结束！" | tee -a /home/openwrt-auto/log.txt
echo "开始时间：$startTime" | tee -a /home/openwrt-auto/log.txt
echo "结束时间：$endTime" | tee -a /home/openwrt-auto/log.txt
if [ $hours -gt 0 ]; then
    echo "总共耗时：$hours 小时 $minutes 分钟 $seconds 秒" | tee -a /home/openwrt-auto/log.txt
elif [ $minutes -gt 0 ]; then
    echo "总共耗时：$minutes 分钟 $seconds 秒" | tee -a /home/openwrt-auto/log.txt
else
    echo "总共耗时：$seconds 秒" | tee -a /home/openwrt-auto/log.txt
fi
