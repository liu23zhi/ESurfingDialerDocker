#!/bin/bash

DOMAIN="enet.10000.gd.cn"
IP1="125.88.59.131"
IP2="61.140.12.23"

# 检查IP1是否可达
if ping -c 1 $IP1 &> /dev/null
then
    PRIMARY_IP=$IP1
else
    PRIMARY_IP=$IP2
fi

# 更新hosts文件
echo "$PRIMARY_IP $DOMAIN" | sudo tee -a /etc/hosts > /dev/null
