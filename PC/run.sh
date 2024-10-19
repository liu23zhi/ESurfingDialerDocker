#!/bin/sh

# 打印环境变量
echo "DIALER_USER: ${DIALER_USER}"
echo "DIALER_PASSWORD: ${DIALER_PASSWORD}"

# 执行 Python 脚本
python3 /app/ESurfingDialerClient/run.py ${DIALER_USER} ${DIALER_PASSWORD}

