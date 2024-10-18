#!/bin/sh
# 挂载 /etc/resolv.conf 为只读模式
mount --bind /etc/resolv.conf /home/zelly/ubuntu/etc/resolv.conf
mount -o bind,ro /etc/resolv.conf /home/zelly/ubuntu/etc/resolv.conf

# 挂载 proc 为只读模式
mount -t proc -o ro proc /home/zelly/ubuntu/proc

# 挂载本地 /dev/pts 到虚拟环境
mkdir -p /home/zelly/ubuntu/dev/pts
sudo mount -t devpts devpts /home/zelly/ubuntu/dev/pts

# 补全虚拟环境
touch /home/zelly/ubuntu/dev/null
chmod -R 777 /home/zelly/ubuntu/dev/null
mkdir /home/zelly/ubuntu/tmp
chmod -R 777 /home/zelly/ubuntu/tmp