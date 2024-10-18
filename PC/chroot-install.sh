#!/bin/sh

# 安装必要的软件包
apt install sudo inetutils-ping python3

# 预设时区配置
echo 'tzdata tzdata/Areas select Asia' | debconf-set-selections
echo 'tzdata tzdata/Zones/Asia select Shanghai' | debconf-set-selections

# 无人值守安装 python3
DEBIAN_FRONTEND=noninteractive apt-get install -y python3

# 安装其他必要的软件包
apt install python-is-python3 iproute2 python3-pip

# 安装 Python 包
pip3 install netifaces
pip3 install psutil


#取消挂载
#sudo umount /home/zelly/ubuntu/etc/resolv.conf
#sudo umount /home/zelly/ubuntu/proc
#sudo umount /home/zelly/ubuntu/dev/pts



#配置中国电信客户端运行环境
chmod -R 777 /app/ESurfingDialerClient/tyxy
cd /app/ESurfingDialerClient/tyxy
/app/ESurfingDialerClient/tyxy