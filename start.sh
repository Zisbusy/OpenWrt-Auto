#!/bin/bash
echo "测试网络代理..."
if ping -c 1 192.168.10.10 &> /dev/null; then
    echo "代理地址有效 - 设置代理"
    echo "设置本地网络代理：192.168.10.10:7890"
    export http_proxy=http://192.168.10.10:7890
    export https_proxy=http://192.168.10.10:7890
else
    echo "代理地址无效 - 不设置代理"
fi

echo "安装 git 工具..."
dnf -y install git

echo "克隆 immortalwrt-auto 源码..."
git clone https://github.com/Zisbusy/immortalwrt-auto.git /home/immortalwrt-auto

echo "执行自动化脚本..."
chmod 777 /home/immortalwrt-auto/23.05.2/run.sh
sh /home/immortalwrt-auto/23.05.2/run.sh $1
