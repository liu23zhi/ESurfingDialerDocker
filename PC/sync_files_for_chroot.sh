#!/bin/bash

# 创建目标目录（如果不存在）
mkdir -p /app/proc/net

# 定期检查和同步文件
while true; do
    # 检查并创建目标文件（如果不存在）
    if [ ! -f /app/proc/net/route ]; then
        touch /app/proc/net/route
    fi
    if [ ! -f /app/proc/net/ipv6_route ]; then
        touch /app/proc/net/ipv6_route
    fi
    if [ ! -f /app/etc/resolv.conf ]; then
        mkdir -p /app/etc
        touch /app/etc/resolv.conf
    fi

    # 同步文件内容
    cp /proc/net/route /app/proc/net/route
    cp /proc/net/ipv6_route /app/proc/net/ipv6_route
    cp /etc/resolv.conf /app/etc/resolv.conf

    sleep 1
done
