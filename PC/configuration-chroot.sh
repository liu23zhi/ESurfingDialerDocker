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
echo "开启文件监控"
nohup /app/sync_files_for_chroot.sh &

# # 挂载本地 /dev/pts 到虚拟环境
# mkdir -p /app/ubuntu-base/dev/pts
# sudo mount -t devpts devpts /app/ubuntu-base/dev/pts
# sudo dmesg | tail
#没有用，不挂载了

# # 预设时区配置
echo 'tzdata tzdata/Areas select Asia' | debconf-set-selections
echo 'tzdata tzdata/Zones/Asia select Shanghai' | debconf-set-selections

# # 无人值守安装 expect
echo "检查 expect 安装情况"
if test -e "/usr/bin/expect"; then
  echo "/usr/bin/expect 存在，跳过安装"
else
  echo "/usr/bin/expect 不存在，执行无人值守安装"
  DEBIAN_FRONTEND=noninteractive apt-get install -y expect
fi


#创建一些必须的文件
mkdir -p /app/ubuntu-base/usr/lib/tmpfiles.d/
touch /app/ubuntu-base/usr/lib/tmpfiles.d/systemd-network.conf
touch /app/ubuntu-base/usr/lib/tmpfiles.d/systemd.conf
chmod -R 777 /app/ubuntu-base/usr/lib/tmpfiles.d/

# 补全虚拟环境

mkdir -p /app/ubuntu-base/tmp
sudo chmod -R 777 /app/ubuntu-base/tmp

# 复制qemu到chroot中备用
sudo cp /usr/bin/qemu-x86_64-static /app/ubuntu-base/usr/bin/

#将变量写入chroot

mkdir -p /app/ubuntu-base/app/

# 创建或清空env_vars.sh文件
> /app/ubuntu-base/app/env_vars.sh

echo "开始导出环境变量"
echo "echo \"开始传递账号密码\"" >> /app/ubuntu-base/app/env_vars.sh

# 导出环境变量
echo "export DIALER_USER=$DIALER_USER" >> /app/ubuntu-base/app/env_vars.sh
echo "export DIALER_PASSWORD=$DIALER_PASSWORD" >> /app/ubuntu-base/app/env_vars.sh

# 添加更多的环境变量用于帮助python区分系统
if test "$1" = "arm"; then
    echo "export system=arm" >> /app/ubuntu-base/app/env_vars.sh
else
    echo "export system=amd" >> /app/ubuntu-base/app/env_vars.sh
fi

# 显示环境变量
echo "echo \"账号用户名（DIALER_USER）: \$DIALER_USER\"" >> /app/ubuntu-base/app/env_vars.sh
echo "echo \"账号密码（DIALER_PASSWORD）: \$DIALER_PASSWORD\"" >> /app/ubuntu-base/app/env_vars.sh

# 运行主程序
echo "echo \"开始运行主程序\"" >> /app/ubuntu-base/app/env_vars.sh
echo "cd /app/ESurfingDialerClient/" >> /app/ubuntu-base/app/env_vars.sh
# echo "ls -l " >> /app/ubuntu-base/app/env_vars.sh

if test "$1" = "arm"; then
    echo "/usr/bin/qemu-x86_64-static /usr/bin/bash -c z -R 777 /app/ESurfingDialerClient/run.sh" >> /app/ubuntu-base/app/env_vars.sh
    echo "/usr/bin/qemu-x86_64-static /usr/bin/bash -c /app/ESurfingDialerClient/run.sh" >> /app/ubuntu-base/app/env_vars.sh
else
    echo "chmod -R 777 /app/ESurfingDialerClient/run.sh" >> /app/ubuntu-base/app/env_vars.sh
    echo "bash /app/ESurfingDialerClient/run.sh" >> /app/ubuntu-base/app/env_vars.sh
fi


# 追加 run.sh 的内容到 env_vars.sh
#echo "开始准备运行参数"
#echo "获取到参数内容"
#cat /app/ubuntu-base/app/ESurfingDialerClient/run.sh
#cat /app/ubuntu-base/app/ESurfingDialerClient/run.sh >> /app/ubuntu-base/app/env_vars.sh
#echo "写入后内容"
#cat /app/ubuntu-base/app/env_vars.sh
#echo "ls -l /app/ESurfingDialerClient/run.sh" >> /app/ubuntu-base/app/env_vars.sh
#echo "/bin/sh -c \"/app/ESurfingDialerClient/run.sh\"" >> /app/ubuntu-base/app/env_vars.sh

#别循环了，艹
echo "exit" >> /app/ubuntu-base/app/env_vars.sh

sudo chmod -R 777 /app/ubuntu-base/app/env_vars.sh
# ls -l /app/ubuntu-base/app/ESurfingDialerClient/
sudo chmod -R 777 /app/ubuntu-base/app/ESurfingDialerClient/run.sh

#sleep infinity

if test "$1" = "true"; then


# sudo chroot /app/ubuntu-base "/app/env_vars.sh" && exit

# 创建 run_chroot.exp 文件并写入 expect 脚本内容
#touch ./run_chroot.exp
cat > /app/run_chroot.exp << 'EOF'
#!/usr/bin/expect -f

# 设置超时时间，以防某些操作需要更长时间
set timeout -1

# 启动 chroot 环境
spawn sudo chroot /app/ubuntu-base "/usr/bin/sh"

# 等待 shell 提示符出现
expect "#"

# 发送命令到 chroot 环境
send "/app/env_vars.sh && exit\r"

# 等待命令执行完成
expect eof
EOF

# 设置 run_chroot.exp 文件的执行权限
chmod +x /app/run_chroot.exp

ls -l /app/run_chroot.exp

# 执行 run_chroot.exp 文件
/usr/bin/expect /app/run_chroot.exp

elif test "$1" = "arm"; then

# sudo chroot /app/ubuntu-base "/app/env_vars.sh" && exit

# 创建 run_chroot.exp 文件并写入 expect 脚本内容
#touch ./run_chroot.exp
cat > /app/run_chroot.exp << 'EOF'
#!/usr/bin/expect -f

# 设置超时时间，以防某些操作需要更长时间
set timeout -1

# 启动 chroot 环境
spawn sudo chroot /app/ubuntu-base "/usr/bin/sh"

# 等待 shell 提示符出现
expect "#"

# 发送命令到 chroot 环境
send "/usr/bin/qemu-x86_64-static /usr/bin/bash -c /app/env_vars.sh && exit\r"

# 等待命令执行完成
expect eof
EOF

# 设置 run_chroot.exp 文件的执行权限
chmod +x /app/run_chroot.exp

ls -l /app/run_chroot.exp

# 执行 run_chroot.exp 文件
/usr/bin/expect /app/run_chroot.exp


fi