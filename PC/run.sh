#!/bin/sh

# 读取环境变量
# sudo chmod -R 777 /app/env_vars.sh
# /app/env_vars.sh
# 靠，成死循环了，害我排查这么久

# 打印环境变量
echo "账号用户名（DIALER_USER）: ${DIALER_USER}"
echo "账号密码（DIALER_PASSWORD）: ${DIALER_PASSWORD}"
echo "当前系统为：${system}"

if test "$1" = "true"; then
    # 执行 Python 脚本
    if ${system}=="arm"; then
        /usr/bin/qemu-x86_64-static /usr/bin/bash -c /usr/bin/python3 /app/ESurfingDialerClient/run.py ${DIALER_USER} ${DIALER_PASSWORD} --use_qemu
    elif ${system}=="amd"; then
        python3 /app/ESurfingDialerClient/run.py ${DIALER_USER} ${DIALER_PASSWORD}
    fi
fi