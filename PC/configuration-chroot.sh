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

#确保文件夹存在
mkdir -p /app/ubuntu-base/proc/net

if [ ! -f /app/ubuntu-base/proc/net/route ]; then
    touch /app/ubuntu-base/proc/net/route
fi
if [ ! -f /app/ubuntu-base/proc/net/ipv6_route ]; then
    touch /app/ubuntu-base/proc/net/ipv6_route
fi
if [ ! -f /app/ubuntu-base/etc/resolv.conf ]; then
    mkdir -p /app/ubuntu-base/etc
    touch /app/ubuntu-base/etc/resolv.conf
fi

cp /proc/net/route /app/ubuntu-base/proc/net/route

cp /proc/net/ipv6_route /app/ubuntu-base/proc/net/ipv6_route

cp /etc/resolv.conf /app/ubuntu-base/etc/resolv.conf

#确保/dev/null权限正确
sudo chmod -R 777 /app/ubuntu-base/dev/null

if [ ! -f /app/ubuntu-base/dev/null ]; then
    mkdir -p /app/ubuntu-base/dev/
    touch /app/ubuntu-base/dev/null
    chmod -R 777 /app/ubuntu-base/dev/null
fi


# 定期同步文件
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

#将变量写入chroot
echo -e "echo \"开始传递账号密码\"" > /app/ubuntu-base/app/env_vars.sh
echo "echo \"账号用户名（DIALER_USER）: ${DIALER_USER}\"" >> /app/ubuntu-base/app/env_vars.sh
echo "echo \"账号密码（DIALER_PASSWORD）: ${DIALER_PASSWORD}\"" >> /app/ubuntu-base/app/env_vars.sh

echo "export DIALER_USER=$DIALER_USER" >> /app/ubuntu-base/app/env_vars.sh
echo "export DIALER_PASSWORD=$DIALER_PASSWORD" >> /app/ubuntu-base/app/env_vars.sh
echo -e "echo \"开始运行主程序\"" >> /app/ubuntu-base/app/env_vars.sh
echo "cd /app/ESurfingDialerClient/" >> /app/ubuntu-base/app/env_vars.sh
echo "/app/ESurfingDialerClient/run.sh" >> /app/ubuntu-base/app/env_vars.sh

sudo chmod -R 777 /app/ubuntu-base/app/env_vars.sh
sudo chmod -R 777 /app/ubuntu-base/app/ESurfingDialerClient/run.sh

sudo chroot /app/ubuntu-base /app/env_vars.sh