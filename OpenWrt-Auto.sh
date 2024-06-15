#!/bin/bash
# 开始计时
startTime=$(date +%Y%m%d-%H:%M:%S)
startTime_s=$(date +%s)

# 执行
echo "自动化编译官方 OpenWrt" | tee -a /home/OpenWrt-Auto/log.txt
echo "工作目录：/home" | tee -a /home/OpenWrt-Auto/log.txt
cd /home

echo "测试网络代理..." | tee -a /home/OpenWrt-Auto/log.txt
if ping -c 1 192.168.10.10 &> /dev/null; then
    echo "代理地址有效 - 设置代理" | tee -a /home/OpenWrt-Auto/log.txt
    echo "设置本地网络代理：192.168.10.10:7890" | tee -a /home/OpenWrt-Auto/log.txt
    export http_proxy=http://192.168.10.10:7890
    export https_proxy=http://192.168.10.10:7890
else
    echo "代理地址无效 - 不设置代理" | tee -a /home/OpenWrt-Auto/log.txt
fi

echo "安装一些编译要用的包..." | tee -a /home/OpenWrt-Auto/log.txt
dnf -y install git perl wget rsync bzip2 patch tar ncurses-devel epel-release
# dnf -y install screen

echo "克隆 OpenWrt 源码..." | tee -a /home/OpenWrt-Auto/log.txt
git clone https://github.com/openwrt/openwrt.git

echo "设置 OpenWrt 版本 v23.05.3" | tee -a /home/OpenWrt-Auto/log.txt
cd /home/openwrt
git checkout v23.05.3

echo "更新 OpenWrt 源..." | tee -a /home/OpenWrt-Auto/log.txt
./scripts/feeds update -a
echo "安装下载好的包: (可选)..." | tee -a /home/OpenWrt-Auto/log.txt
./scripts/feeds install -a

echo "安装一些第三方包和一些设置..." | tee -a /home/OpenWrt-Auto/log.txt
cd /home/openwrt/package

echo "安装主题 Argon..." | tee -a /home/OpenWrt-Auto/log.txt
git clone https://github.com/jerrykuku/luci-theme-argon.git
echo "合并主题修改..." | tee -a /home/OpenWrt-Auto/log.txt
rm -rf /home/openwrt/package/luci-theme-argon/luasrc/view/themes/argon/footer_login.htm
rm -rf /home/openwrt/package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
cp -rf /home/OpenWrt-Auto/file/argon/footer_login.htm /home/openwrt/package/luci-theme-argon/luasrc/view/themes/argon/
cp -rf /home/OpenWrt-Auto/file/argon/footer.htm /home/openwrt/package/luci-theme-argon/luasrc/view/themes/argon/

echo "安装应用 Luci-app-diskman..." | tee -a /home/OpenWrt-Auto/log.txt
git clone https://github.com/lisaac/luci-app-diskman.git

echo "安装应用 DockerMan..." | tee -a /home/OpenWrt-Auto/log.txt
git clone https://github.com/lisaac/luci-app-dockerman.git
echo "删除官方 DockerMan..." | tee -a /home/OpenWrt-Auto/log.txt
rm -rf /home/openwrt/package/feeds/luci/luci-app-dockerman
echo "复制新的 DockerMan..." | tee -a /home/OpenWrt-Auto/log.txt
cp -rf /home/openwrt/package/luci-app-dockerman/applications/luci-app-dockerman /home/openwrt/package/feeds/luci/luci-app-dockerman

echo "设置：WAN口绑定 eth0、LAN口绑定 eth1..." | tee -a /home/OpenWrt-Auto/log.txt
rm -rf /home/openwrt/package/base-files/files/etc/board.d/99-default_network
cp -rf /home/OpenWrt-Auto/file/99-default_network /home/openwrt/package/base-files/files/etc/board.d/

echo "设置：时区 Asia/Shanghai、NTP 服务器..." | tee -a /home/OpenWrt-Auto/log.txt
rm -rf /home/openwrt/package/base-files/files/bin/config_generate
cp -rf /home/OpenWrt-Auto/file/config_generate /home/openwrt/package/base-files/files/bin/

echo "复制编译配置文件..." | tee -a /home/OpenWrt-Auto/log.txt
cp -rf /home/OpenWrt-Auto/file/.config /home/openwrt/

# 执行脚本
echo "定位到 OpenWrt 工作目录：/home/openwrt" | tee -a /home/OpenWrt-Auto/log.txt
cd /home/openwrt

echo "允许 Root 用户编译" | tee -a /home/OpenWrt-Auto/log.txt
export FORCE_UNSAFE_CONFIGURE=1

echo "获取 CPU 核心数" | tee -a /home/OpenWrt-Auto/log.txt
num=`cat /proc/cpuinfo |grep processor  | wc -l` 
echo "开始编译 - "$num"线程" | tee -a /home/OpenWrt-Auto/log.txt
make -j$num V=s

# 计算时间并输出
endTime=$(date +%Y%m%d-%H:%M:%S)
endTime_s=$(date +%s)
sumTime=$((endTime_s - startTime_s))
hours=$((sumTime / 3600))
minutes=$((sumTime % 3600 / 60))
seconds=$((sumTime % 60))
echo "编译结束！" | tee -a /home/OpenWrt-Auto/log.txt
echo "开始时间：$startTime" | tee -a /home/OpenWrt-Auto/log.txt
echo "结束时间：$endTime" | tee -a /home/OpenWrt-Auto/log.txt
if [ $hours -gt 0 ]; then
    echo "总共耗时：$hours 小时 $minutes 分钟 $seconds 秒" | tee -a /home/OpenWrt-Auto/log.txt
elif [ $minutes -gt 0 ]; then
    echo "总共耗时：$minutes 分钟 $seconds 秒" | tee -a /home/OpenWrt-Auto/log.txt
else
    echo "总共耗时：$seconds 秒" | tee -a /home/OpenWrt-Auto/log.txt
fi

# 邮件通知设备
