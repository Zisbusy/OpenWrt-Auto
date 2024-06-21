# OpenWrt-Auto
基于官方 OpenWrt 编译 x86 固件
自动化编译脚本，环境部署到编译完成。      

# 脚本环境     
基于 Rocky Linux 编写，使用 Root 账号进行编译。      
高度理想化，无任何错误判断，需自行观察是否有错误日志。      
需要自备代理软件，并修改脚本内 192.168.10.10 的地址（中国大陆地区以外的网络环境可以直接取消代理）

# 如何使用
执行下面代码
```shell
dnf -y install git
git clone https://github.com/Zisbusy/OpenWrt-Auto.git /home/OpenWrt-Auto
chmod 777 /home/OpenWrt-Auto/OpenWrt-Auto.sh
```
根据需求修改脚本 OpenWrtAuto.sh 如代理地址      
```shell
# 执行脚本
sh /home/OpenWrt-Auto/OpenWrt-Auto.sh
```

清理本项目产生的所有文件      
```shell
# 执行脚本
chmod 777 /home/OpenWrt-Auto/clean.sh
sh /home/OpenWrt-Auto/clean.sh
```

# 说明  
本固件高度自定义，贴近个人使用场景。      
 - 基础上网功能（默认 OpenWrt 配置）
 - 默认支持 ipv6      
 - 添加 UPNP
 - 添加主题 Argon      
 - 添加 磁盘管理 Diskman      
 - 添加 挂载功能
 - 添加三方 Docker
 - eth0 默认 WAN 口
 - 调整时区为 Asia/Shanghai
 - 更改 ntp 服务地址
 - 更改 默认网关 192.168.10.1      


# 使用的项目

Argon **https://github.com/jerrykuku/luci-theme-argon**      
Docker **https://github.com/lisaac/luci-app-dockerman**      
Diskman **https://github.com/lisaac/luci-app-diskman**      
