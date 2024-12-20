#!/bin/sh
apt update
# 安装必要的软件包
apt install -y sudo inetutils-ping python3 curl wget dialog

# 预设时区配置
echo 'tzdata tzdata/Areas select Asia' | debconf-set-selections
echo 'tzdata tzdata/Zones/Asia select Shanghai' | debconf-set-selections

# 无人值守安装 python3
echo ”无人值守安装 python3“
DEBIAN_FRONTEND=noninteractive apt-get install -y python3

# echo ”无人值守安装 qemu“
# 怎么感觉安装到chroot环境里面去了
# DEBIAN_FRONTEND=noninteractive apt-get install -y qemu-user-static qemu-system-x86

# 安装其他必要的软件包
apt install -y python-is-python3 iproute2 python3-pip

# 安装 Python 包
# pip3 install netifaces
# pip3 install psutil
apt install -y python3-netifaces python3-psutil

#取消挂载
#sudo umount /home/zelly/ubuntu/etc/resolv.conf
#sudo umount /home/zelly/ubuntu/proc
#sudo umount /home/zelly/ubuntu/dev/pts


# 预设时区配置
echo 'tzdata tzdata/Areas select Asia' | debconf-set-selections
echo 'tzdata tzdata/Zones/Asia select Shanghai' | debconf-set-selections

# 无人值守安装 expect
echo "无人值守安装 expect"
DEBIAN_FRONTEND=noninteractive apt-get install -y expect


#配置中国电信客户端运行环境
echo "开始配置中国电信客户端运行环境"
chmod -R 777 /app/ESurfingDialerClient/tyxy
cd /app/ESurfingDialerClient/
/app/ESurfingDialerClient/tyxy
echo "配置中国电信客户端运行环境执行完毕"