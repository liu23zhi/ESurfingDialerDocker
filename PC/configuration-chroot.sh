#!/bin/sh
# 挂载 /etc/resolv.conf 为只读模式
# DNs解析服务
# sudo chmod -R 777 /app/ubuntu-base/etc/resolv.conf
# sudo chmod -R 777 /etc/resolv.conf
# sudo mount --bind /etc/resolv.conf /app/ubuntu-base/etc/resolv.conf
# sudo dmesg | tail
# sudo mount -o bind,ro /etc/resolv.conf /app/ubuntu-base/etc/resolv.conf
# sudo dmesg | tail
#不干了，直接复制
#sudo cp -a /etc/resolv.conf /app/ubuntu-base/etc/resolv.conf

# 挂载 proc 为只读模式
# sudo mount -t proc -o ro proc /app/ubuntu-base/proc
# sudo dmesg | tail
# 挂载不了
# /proc/net/route
# /proc/net/ipv6_route

#改用自动监控

sudo chmod -R 777 /app/sync_files_for_chroot.sh
cp /proc/net/route /app/ubuntu-base/proc/net/route
cp /proc/net/ipv6_route /app/ubuntu-base/proc/net/ipv6_route
cp /etc/resolv.conf /app/ubuntu-base/etc/resolv.conf
nohup /app/sync_files_for_chroot.sh &

# # 挂载本地 /dev/pts 到虚拟环境
# mkdir -p /app/ubuntu-base/dev/pts
# sudo mount -t devpts devpts /app/ubuntu-base/dev/pts
# sudo dmesg | tail
#没有用，不挂载了


# 补全虚拟环境
if [ ! -d /app/ubuntu-base/tmp ]; then
    mkdir /app/ubuntu-base/tmp
fi
sudo chmod -R 777 /app/ubuntu-base/tmp