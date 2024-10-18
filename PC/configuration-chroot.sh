#!/bin/sh
# 挂载 /etc/resolv.conf 为只读模式
mount --bind /etc/resolv.conf /app/ubuntu-base/etc/resolv.conf
mount -o bind,ro /etc/resolv.conf /app/ubuntu-base/etc/resolv.conf

# 挂载 proc 为只读模式
mount -t proc -o ro proc /app/ubuntu-base/proc

# 挂载本地 /dev/pts 到虚拟环境
mkdir -p /app/ubuntu-base/dev/pts
mount -t devpts devpts /app/ubuntu-base/dev/pts

# 补全虚拟环境
touch /app/ubuntu-base/dev/null
chmod -R 777 /app/ubuntu-base/dev/null
mkdir /app/ubuntu-base/tmp
chmod -R 777 /app/ubuntu-base/tmp