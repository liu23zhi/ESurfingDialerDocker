#!/bin/sh
# 挂载 /etc/resolv.conf 为只读模式
mount --bind /etc/resolv.conf /app/ubuntu-base/etc/resolv.conf
dmesg | tail
mount -o bind,ro /etc/resolv.conf /app/ubuntu-base/etc/resolv.conf
dmesg | tail

# 挂载 proc 为只读模式
mount -t proc -o ro proc /app/ubuntu-base/proc
dmesg | tail

# 挂载本地 /dev/pts 到虚拟环境
mkdir -p /app/ubuntu-base/dev/pts
mount -t devpts devpts /app/ubuntu-base/dev/pts
dmesg | tail

# 补全虚拟环境
if [ ! -d /app/ubuntu-base/tmp ]; then
    mkdir /app/ubuntu-base/tmp
fi
chmod -R 777 /app/ubuntu-base/tmp