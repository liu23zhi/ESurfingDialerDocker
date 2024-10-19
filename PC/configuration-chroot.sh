#!/bin/sh
# 挂载 /etc/resolv.conf 为只读模式
sudo mount --bind /etc/resolv.conf /app/ubuntu-base/etc/resolv.conf
sudo dmesg | tail
sudo mount -o bind,ro /etc/resolv.conf /app/ubuntu-base/etc/resolv.conf
sudo dmesg | tail

# 挂载 proc 为只读模式
sudo mount -t proc -o ro proc /app/ubuntu-base/proc
sudo dmesg | tail

# 挂载本地 /dev/pts 到虚拟环境
mkdir -p /app/ubuntu-base/dev/pts
sudo mount -t devpts devpts /app/ubuntu-base/dev/pts
sudo dmesg | tail

# 补全虚拟环境
if [ ! -d /app/ubuntu-base/tmp ]; then
    mkdir /app/ubuntu-base/tmp
fi
sudo chmod -R 777 /app/ubuntu-base/tmp