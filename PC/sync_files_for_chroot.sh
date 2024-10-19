#!/bin/bash

# 创建目标目录（如果不存在）
mkdir -p /app/ubuntu-base/proc/net

# 定期检查和同步文件
while true; do
    # 检查并创建目标文件（如果不存在）
    if [ ! -f /app/ubuntu-base/proc/net/route ]; then
        touch /app/ubuntu-base/proc/net/route
    fi
    if [ ! -f /app/ubuntu-base/proc/net/ipv6_route ]; then
        touch /app/ubuntu-base/proc/net/ipv6_route
    fi
    # if [ ! -f /app/ubuntu-base/etc/resolv.conf ]; then
    #     mkdir -p /app/ubuntu-base/etc
    #     touch /app/ubuntu-base/etc/resolv.conf
    # fi

    # 同步文件内容
    cp /proc/net/route /app/ubuntu-base/proc/net/route
    cp /proc/net/ipv6_route /app/ubuntu-base/proc/net/ipv6_route
    cp /etc/resolv.conf /app/ubuntu-base/etc/resolv.conf

    sleep 1
done
